import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_resources/core/database/app_database.dart';
import 'package:smart_resources/core/network/network_service.dart';
import 'package:smart_resources/features/auth/data/models/user_model.dart';
import 'package:smart_resources/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:smart_resources/features/resources/data/models/resource_model.dart';
import 'package:smart_resources/features/resources/data/models/review_model.dart';
import 'package:smart_resources/features/resources/data/repositories/resource_repository_impl.dart';
import 'package:smart_resources/features/requests/data/models/request_model.dart';
import 'package:smart_resources/features/requests/data/repositories/request_repository_impl.dart';
import 'package:smart_resources/features/notifications/data/models/notification_model.dart';
import 'package:smart_resources/features/notifications/data/repositories/notification_repository_impl.dart';

// ─── Mocks ───────────────────────────────────────────────────────────────────

class MockNetworkService extends Mock implements NetworkService {}

class MockAppDatabase extends Mock implements AppDatabase {}

// ─── Fakes (needed for mocktail registerFallbackValue) ───────────────────────

class FakeUserModel extends Fake implements UserModel {}

class FakeResourceModel extends Fake implements ResourceModel {}

class FakeReviewModel extends Fake implements ReviewModel {}

class FakeRequestModel extends Fake implements RequestModel {}

class FakeNotificationModel extends Fake implements NotificationModel {}

// ─── Sample fixtures ──────────────────────────────────────────────────────────

UserModel _sampleUser({
  String id = 'user-001',
  String name = 'Alice',
  String email = 'alice@test.com',
  String password = 'pass123',
  String role = 'User',
  String status = 'active',
}) => UserModel(
  id: id,
  name: name,
  email: email,
  password: password,
  role: role,
  status: status,
);

ResourceModel _sampleResource({
  String id = 'res-001',
  String title = 'Calculus Notes',
  bool isApproved = false,
  bool isBookmarked = false,
  bool isDownloaded = false,
}) => ResourceModel(
  id: id,
  title: title,
  description: 'Detailed notes on calculus',
  courseCode: 'MATH101',
  rating: 4.2,
  reviewCount: 5,
  uses: 10,
  fileType: 'PDF',
  uploader: 'alice@test.com',
  isApproved: isApproved,
  isBookmarked: isBookmarked,
  isDownloaded: isDownloaded,
);

RequestModel _sampleRequest({String id = 'req-001', String status = 'open'}) =>
    RequestModel(
      id: id,
      title: 'Request Organic Chemistry Notes',
      description: 'Need notes for chapter 4',
      courseCode: 'CHEM201',
      requestedBy: 'alice@test.com',
      time: '2024-01-15T10:00:00Z',
      status: status,
    );

ReviewModel _sampleReview({String resourceId = 'res-001'}) => ReviewModel(
  id: 'rev-001',
  resourceId: resourceId,
  userId: 'user-001',
  userName: 'Alice',
  rating: 5.0,
  comment: 'Excellent resource!',
  time: '2024-01-15T11:00:00Z',
);

NotificationModel _sampleNotification({
  String id = 'notif-001',
  bool isRead = false,
  String time = '2024-01-15T12:00:00Z',
}) => NotificationModel(
  id: id,
  title: 'New Resource Available',
  message: 'Calculus Notes have been approved.',
  time: time,
  isRead: isRead,
);

// ─── Helpers ──────────────────────────────────────────────────────────────────

/// Stubs db.query() to return [rows] for any call.
void _stubQuery(MockAppDatabase db, List<Map<String, Object?>> rows) {
  when(
    () => db.query(
      any(),
      distinct: any(named: 'distinct'),
      columns: any(named: 'columns'),
      where: any(named: 'where'),
      whereArgs: any(named: 'whereArgs'),
      groupBy: any(named: 'groupBy'),
      having: any(named: 'having'),
      orderBy: any(named: 'orderBy'),
      limit: any(named: 'limit'),
      offset: any(named: 'offset'),
    ),
  ).thenAnswer((_) async => rows);
}

void _stubInsert(MockAppDatabase db) {
  when(() => db.insert(any(), any())).thenAnswer((_) async => 1);
}

void _stubUpdate(MockAppDatabase db) {
  when(
    () => db.update(
      any(),
      any(),
      where: any(named: 'where'),
      whereArgs: any(named: 'whereArgs'),
    ),
  ).thenAnswer((_) async => 1);
}

void _stubDelete(MockAppDatabase db) {
  when(
    () => db.delete(
      any(),
      where: any(named: 'where'),
      whereArgs: any(named: 'whereArgs'),
    ),
  ).thenAnswer((_) async => 1);
}

void _stubPersistDownload(MockAppDatabase db) {
  when(() => db.persistDownloadedId(any())).thenAnswer((_) async {});
}

void _stubGetPersistedDownloadedIds(MockAppDatabase db, [Set<String>? ids]) {
  when(() => db.getPersistedDownloadedIds())
      .thenAnswer((_) async => ids ?? {});
}

// ══════════════════════════════════════════════════════════════════════════════
//  TESTS
// ══════════════════════════════════════════════════════════════════════════════

void main() {
  setUpAll(() {
    registerFallbackValue(FakeUserModel());
    registerFallbackValue(FakeResourceModel());
    registerFallbackValue(FakeReviewModel());
    registerFallbackValue(FakeRequestModel());
    registerFallbackValue(FakeNotificationModel());
  });

  // --------------------------------------------------------------------------
  // AUTH REPOSITORY
  // --------------------------------------------------------------------------
  group('AuthRepositoryImpl', () {
    late MockAppDatabase db;
    late MockNetworkService mockNet;
    late AuthRepositoryImpl repo;

    setUp(() {
      db = MockAppDatabase();
      mockNet = MockNetworkService();
      repo = AuthRepositoryImpl(database: db, network: mockNet);
    });

    // ── login ─────────────────────────────────────────────────────────────────
    test('login returns cached user when present in DB', () async {
      final user = _sampleUser();
      _stubQuery(db, [user.toMap()]);

      final result = await repo.login(user.email, user.password);

      verifyNever(() => mockNet.authenticate(any(), any()));
      expect(result.id, user.id);
      expect(result.name, user.name);
    });

    test('login hits network when cache is empty and stores result', () async {
      final user = _sampleUser();
      _stubQuery(db, []);
      _stubInsert(db);
      when(
        () => mockNet.authenticate(user.email, user.password),
      ).thenAnswer((_) async => user);

      final result = await repo.login(user.email, user.password);

      verify(() => mockNet.authenticate(user.email, user.password)).called(1);
      verify(() => db.insert('users', any())).called(1);
      expect(result.id, user.id);
    });

    test('login throws AuthException on bad credentials', () async {
      _stubQuery(db, []);
      when(
        () => mockNet.authenticate(any(), any()),
      ).thenAnswer((_) async => null);

      expect(
        () => repo.login('bad@test.com', 'wrong'),
        throwsA(isA<AuthException>()),
      );
    });

    // ── signup ────────────────────────────────────────────────────────────────
    test('signup registers user on network and caches locally', () async {
      final user = _sampleUser();
      _stubInsert(db);
      when(() => mockNet.register(any())).thenAnswer((_) async => user);

      final result = await repo.signup(user.name, user.email, user.password);

      verify(() => mockNet.register(any())).called(1);
      verify(() => db.insert('users', any())).called(1);
      expect(result.email, user.email);
    });

    // ── updateProfile ─────────────────────────────────────────────────────────
    test('updateProfile syncs to network and updates local cache', () async {
      final user = _sampleUser();
      // updateProfile fetches users list to find existing role/status,
      // then calls updateUser, then inserts updated user into cache
      _stubQuery(db, [user.toMap()]);
      _stubInsert(db);
      when(() => mockNet.fetchUsers()).thenAnswer((_) async => [user]);
      when(() => mockNet.updateUser(any())).thenAnswer((_) async {});

      final updated = await repo.updateProfile(
        user.id,
        'Alice Updated',
        'alice2@test.com',
        'newpass',
      );

      verify(() => mockNet.updateUser(any())).called(1);
      verify(() => db.insert('users', any())).called(1);
      expect(updated.name, 'Alice Updated');
      expect(updated.email, 'alice2@test.com');
    });

    // ── getUsers ──────────────────────────────────────────────────────────────
    test('getUsers always fetches from network and caches locally', () async {
      final user = _sampleUser();
      _stubInsert(db);
      when(() => mockNet.fetchUsers()).thenAnswer((_) async => [user]);

      final users = await repo.getUsers();

      verify(() => mockNet.fetchUsers()).called(1);
      verify(() => db.insert('users', any())).called(1);
      expect(users.length, 1);
    });

    test('getUsers falls back to local cache when network fails', () async {
      final user = _sampleUser();
      _stubQuery(db, [user.toMap()]);
      when(() => mockNet.fetchUsers()).thenThrow(Exception('Network error'));

      final users = await repo.getUsers();

      expect(users.length, 1);
      expect(users.first.id, user.id);
    });

    test('getUsers fetches from network when cache is empty', () async {
      final remoteUsers = [
        _sampleUser(),
        _sampleUser(id: 'user-002', email: 'bob@test.com'),
      ];
      _stubQuery(db, []);
      _stubInsert(db);
      when(() => mockNet.fetchUsers()).thenAnswer((_) async => remoteUsers);

      final users = await repo.getUsers();

      verify(() => mockNet.fetchUsers()).called(1);
      expect(users.length, 2);
    });

    // ── toggleUserStatus ──────────────────────────────────────────────────────
    test('toggleUserStatus suspends active user', () async {
      final user = _sampleUser(status: 'active');
      _stubQuery(db, [user.toMap()]);
      _stubUpdate(db);
      when(() => mockNet.updateUser(any())).thenAnswer((_) async {});

      await repo.toggleUserStatus(user.id);

      verify(() => mockNet.updateUser(any())).called(1);
      final captured = verify(
        () => db.update(
          'users',
          captureAny(),
          where: any(named: 'where'),
          whereArgs: any(named: 'whereArgs'),
        ),
      ).captured;
      final updatedMap = captured.first as Map<String, Object?>;
      expect(updatedMap['status'], 'suspended');
    });

    test('toggleUserStatus re-activates suspended user', () async {
      final user = _sampleUser(status: 'suspended');
      _stubQuery(db, [user.toMap()]);
      _stubUpdate(db);
      when(() => mockNet.updateUser(any())).thenAnswer((_) async {});

      await repo.toggleUserStatus(user.id);

      final captured = verify(
        () => db.update(
          'users',
          captureAny(),
          where: any(named: 'where'),
          whereArgs: any(named: 'whereArgs'),
        ),
      ).captured;
      final updatedMap = captured.first as Map<String, Object?>;
      expect(updatedMap['status'], 'active');
    });

    // ── deleteUser ────────────────────────────────────────────────────────────
    test('deleteUser removes from DB and calls network', () async {
      _stubDelete(db);
      when(() => mockNet.deleteUser(any())).thenAnswer((_) async {});

      await repo.deleteUser('user-001');

      verify(() => mockNet.deleteUser('user-001')).called(1);
      verify(
        () => db.delete(
          'users',
          where: any(named: 'where'),
          whereArgs: any(named: 'whereArgs'),
        ),
      ).called(1);
    });
  });

  // --------------------------------------------------------------------------
  // RESOURCE REPOSITORY
  // --------------------------------------------------------------------------
  group('ResourceRepositoryImpl', () {
    late MockAppDatabase db;
    late MockNetworkService mockNet;
    late ResourceRepositoryImpl repo;

    setUp(() {
      db = MockAppDatabase();
      mockNet = MockNetworkService();
      repo = ResourceRepositoryImpl(database: db, network: mockNet);
    });

    // ── getResources ──────────────────────────────────────────────────────────
    test(
      'getResources always fetches from network and caches locally',
      () async {
        final res = _sampleResource();
        _stubInsert(db);
        _stubGetPersistedDownloadedIds(db);
        when(() => mockNet.fetchResources()).thenAnswer((_) async => [res]);

        final resources = await repo.getResources();

        verify(() => mockNet.fetchResources()).called(1);
        verify(() => db.insert('resources', any())).called(1);
        expect(resources.length, 1);
        expect(resources.first.title, 'Calculus Notes');
      },
    );

    test('getResources falls back to local cache when network fails', () async {
      final res = _sampleResource();
      _stubQuery(db, [res.toMap()]);
      when(
        () => mockNet.fetchResources(),
      ).thenThrow(Exception('Network error'));

      final resources = await repo.getResources();

      expect(resources.length, 1);
      expect(resources.first.id, res.id);
    });

    test('getResources fetches from network when cache is empty', () async {
      final remote = [
        _sampleResource(),
        _sampleResource(id: 'res-002', title: 'Physics Notes'),
      ];
      _stubQuery(db, []);
      _stubInsert(db);
      _stubGetPersistedDownloadedIds(db);
      when(() => mockNet.fetchResources()).thenAnswer((_) async => remote);

      final resources = await repo.getResources();

      verify(() => mockNet.fetchResources()).called(1);
      expect(resources.length, 2);
    });

    // ── getResourceById ───────────────────────────────────────────────────────
    test('getResourceById returns cached resource', () async {
      final res = _sampleResource();
      _stubQuery(db, [res.toMap()]);

      final result = await repo.getResourceById(res.id);

      verifyNever(() => mockNet.fetchResourceById(any()));
      expect(result?.id, res.id);
    });

    test('getResourceById fetches from network on cache miss', () async {
      final res = _sampleResource();
      _stubQuery(db, []);
      _stubInsert(db);
      when(
        () => mockNet.fetchResourceById(res.id),
      ).thenAnswer((_) async => res);

      final result = await repo.getResourceById(res.id);

      verify(() => mockNet.fetchResourceById(res.id)).called(1);
      expect(result?.id, res.id);
    });

    // ── uploadResource ────────────────────────────────────────────────────────
    test('uploadResource posts to network and caches locally', () async {
      final res = _sampleResource();
      _stubInsert(db);
      when(
        () => mockNet.uploadResource(
          any(),
          fileBytes: any(named: 'fileBytes'),
          fileName: any(named: 'fileName'),
        ),
      ).thenAnswer((_) async => res);

      await repo.uploadResource(res);

      verify(
        () => mockNet.uploadResource(
          any(),
          fileBytes: any(named: 'fileBytes'),
          fileName: any(named: 'fileName'),
        ),
      ).called(1);
      verify(() => db.insert('resources', any())).called(1);
    });

    // ── updateResource ────────────────────────────────────────────────────────
    test('updateResource calls network and updates local cache', () async {
      final res = _sampleResource();
      _stubUpdate(db);
      when(() => mockNet.updateResource(any())).thenAnswer((_) async {});

      final updated = res.copyWith(title: 'Updated Calculus Notes');
      await repo.updateResource(updated);

      verify(() => mockNet.updateResource(any())).called(1);
      verify(
        () => db.update(
          'resources',
          any(),
          where: any(named: 'where'),
          whereArgs: any(named: 'whereArgs'),
        ),
      ).called(1);
    });

    // ── bookmarkResource ──────────────────────────────────────────────────────
    test('bookmarkResource adds bookmark locally and on network', () async {
      final res = _sampleResource();
      _stubQuery(db, [res.toMap()]);
      _stubInsert(db);
      _stubUpdate(db);
      when(() => mockNet.addBookmark(any(), any())).thenAnswer((_) async {});

      await repo.bookmarkResource('user-001', res.id, true);

      verify(() => mockNet.addBookmark('user-001', res.id)).called(1);
      verify(() => db.insert('bookmarks', any())).called(1);
    });

    test('bookmarkResource removes bookmark locally and on network', () async {
      final res = _sampleResource(isBookmarked: true);
      _stubQuery(db, [res.toMap()]);
      _stubDelete(db);
      _stubUpdate(db);
      when(() => mockNet.removeBookmark(any(), any())).thenAnswer((_) async {});

      await repo.bookmarkResource('user-001', res.id, false);

      verify(() => mockNet.removeBookmark('user-001', res.id)).called(1);
      verify(
        () => db.delete(
          'bookmarks',
          where: any(named: 'where'),
          whereArgs: any(named: 'whereArgs'),
        ),
      ).called(1);
    });

    // ── markDownloaded ────────────────────────────────────────────────────────
    test('markDownloaded sets isDownloaded flag and increments uses', () async {
      final res = _sampleResource();
      _stubQuery(db, [res.toMap()]);
      _stubUpdate(db);
      _stubPersistDownload(db);

      await repo.markDownloaded(res.id);

      final captured = verify(
        () => db.update(
          'resources',
          captureAny(),
          where: any(named: 'where'),
          whereArgs: any(named: 'whereArgs'),
        ),
      ).captured;
      final updatedMap = captured.first as Map<String, Object?>;
      expect(updatedMap['isDownloaded'], 1);
      expect(updatedMap['uses'], greaterThan(res.uses));
    });

    // ── approveResource ───────────────────────────────────────────────────────
    test('approveResource updates backend and local cache', () async {
      final res = _sampleResource(isApproved: false);
      _stubQuery(db, [res.toMap()]);
      _stubUpdate(db);
      when(() => mockNet.approveResource(res.id)).thenAnswer((_) async {});

      await repo.approveResource(res.id);

      verify(() => mockNet.approveResource(res.id)).called(1);
      final captured = verify(
        () => db.update(
          'resources',
          captureAny(),
          where: any(named: 'where'),
          whereArgs: any(named: 'whereArgs'),
        ),
      ).captured;
      final updatedMap = captured.first as Map<String, Object?>;
      expect(updatedMap['isApproved'], 1);
    });

    // ── deleteResource ────────────────────────────────────────────────────────
    test('deleteResource removes resource and related data', () async {
      _stubDelete(db);
      when(() => mockNet.deleteResource(any())).thenAnswer((_) async {});

      await repo.deleteResource('res-001');

      verify(() => mockNet.deleteResource('res-001')).called(1);
      // Deletes resources, bookmarks, reviews
      verify(
        () => db.delete(
          any(),
          where: any(named: 'where'),
          whereArgs: any(named: 'whereArgs'),
        ),
      ).called(3);
    });

    // ── addReview ─────────────────────────────────────────────────────────────
    test('addReview saves to backend and updates resource rating', () async {
      final res = _sampleResource();
      final review = _sampleReview();
      _stubQuery(db, [res.toMap()]);
      _stubInsert(db);
      _stubUpdate(db);
      when(() => mockNet.addReview(any())).thenAnswer((_) async => review);

      await repo.addReview(review);

      verify(() => mockNet.addReview(any())).called(1);
      verify(() => db.insert('reviews', any())).called(1);
      // Rating update
      final captured = verify(
        () => db.update(
          'resources',
          captureAny(),
          where: any(named: 'where'),
          whereArgs: any(named: 'whereArgs'),
        ),
      ).captured;
      final updatedMap = captured.first as Map<String, Object?>;
      expect((updatedMap['reviewCount'] as int), greaterThan(res.reviewCount));
    });

    // ── getReviewsForResource ─────────────────────────────────────────────────
    test('getReviewsForResource returns cached reviews', () async {
      final review = _sampleReview();
      _stubQuery(db, [review.toMap()]);

      final reviews = await repo.getReviewsForResource('res-001');

      verifyNever(() => mockNet.fetchReviews(any()));
      expect(reviews.length, 1);
      expect(reviews.first.comment, 'Excellent resource!');
    });

    test('getReviewsForResource falls back to network on cache miss', () async {
      final review = _sampleReview();
      _stubQuery(db, []);
      _stubInsert(db);
      when(() => mockNet.fetchReviews(any())).thenAnswer((_) async => [review]);

      final reviews = await repo.getReviewsForResource('res-001');

      verify(() => mockNet.fetchReviews('res-001')).called(1);
      expect(reviews.length, 1);
    });
  });

  // --------------------------------------------------------------------------
  // REQUEST REPOSITORY
  // --------------------------------------------------------------------------
  group('RequestRepositoryImpl', () {
    late MockAppDatabase db;
    late MockNetworkService mockNet;
    late RequestRepositoryImpl repo;

    setUp(() {
      db = MockAppDatabase();
      mockNet = MockNetworkService();
      repo = RequestRepositoryImpl(database: db, network: mockNet);
    });

    // ── getRequests ───────────────────────────────────────────────────────────
    test('getRequests returns cached requests', () async {
      final req = _sampleRequest();
      _stubQuery(db, [req.toMap()]);

      final requests = await repo.getRequests();

      verifyNever(() => mockNet.fetchRequests());
      expect(requests.length, 1);
    });

    test('getRequests fetches from network on cache miss', () async {
      final remote = [_sampleRequest(), _sampleRequest(id: 'req-002')];
      _stubQuery(db, []);
      _stubInsert(db);
      when(() => mockNet.fetchRequests()).thenAnswer((_) async => remote);

      final requests = await repo.getRequests();

      verify(() => mockNet.fetchRequests()).called(1);
      expect(requests.length, 2);
    });

    // ── createRequest ─────────────────────────────────────────────────────────
    test('createRequest posts to network and caches locally', () async {
      final req = _sampleRequest();
      _stubInsert(db);
      when(() => mockNet.createRequest(any())).thenAnswer((_) async => req);

      await repo.createRequest(req);

      verify(() => mockNet.createRequest(any())).called(1);
      verify(() => db.insert('requests', any())).called(1);
    });

    // ── updateRequest ─────────────────────────────────────────────────────────
    test('updateRequest syncs to network and updates local cache', () async {
      _stubUpdate(db);
      when(() => mockNet.updateRequest(any())).thenAnswer((_) async {});

      final updated = _sampleRequest().copyWith(title: 'Updated Title');
      await repo.updateRequest(updated);

      verify(() => mockNet.updateRequest(any())).called(1);
      verify(
        () => db.update(
          'requests',
          any(),
          where: any(named: 'where'),
          whereArgs: any(named: 'whereArgs'),
        ),
      ).called(1);
    });

    // ── deleteRequest ─────────────────────────────────────────────────────────
    test('deleteRequest removes from network and local cache', () async {
      _stubDelete(db);
      when(() => mockNet.deleteRequest(any())).thenAnswer((_) async {});

      await repo.deleteRequest('req-001');

      verify(() => mockNet.deleteRequest('req-001')).called(1);
      verify(
        () => db.delete(
          'requests',
          where: any(named: 'where'),
          whereArgs: any(named: 'whereArgs'),
        ),
      ).called(1);
    });

    // ── fulfillRequest ────────────────────────────────────────────────────────
    test('fulfillRequest updates status in backend and local cache', () async {
      final req = _sampleRequest(status: 'open');
      final fulfilled = req.copyWith(status: 'fulfilled');
      _stubUpdate(db);
      when(
        () => mockNet.fulfillRequest(req.id),
      ).thenAnswer((_) async => fulfilled);

      await repo.fulfillRequest(req.id);

      verify(() => mockNet.fulfillRequest(req.id)).called(1);
      verify(
        () => db.update(
          'requests',
          any(),
          where: any(named: 'where'),
          whereArgs: any(named: 'whereArgs'),
        ),
      ).called(1);
    });

    test('fulfillRequest is a no-op when network returns null', () async {
      when(
        () => mockNet.fulfillRequest('missing-id'),
      ).thenAnswer((_) async => null);

      await repo.fulfillRequest('missing-id');

      verifyNever(
        () => db.update(
          any(),
          any(),
          where: any(named: 'where'),
          whereArgs: any(named: 'whereArgs'),
        ),
      );
    });
  });

  // --------------------------------------------------------------------------
  // NOTIFICATION REPOSITORY
  // --------------------------------------------------------------------------
  group('NotificationRepositoryImpl', () {
    late MockAppDatabase db;
    late NotificationRepositoryImpl repo;

    setUp(() {
      db = MockAppDatabase();
      repo = NotificationRepositoryImpl(database: db);
    });

    // ── addNotification ───────────────────────────────────────────────────────
    test('addNotification persists notification to DB', () async {
      _stubInsert(db);
      final notif = _sampleNotification();

      await repo.addNotification(notif);

      final captured = verify(
        () => db.insert('notifications', captureAny()),
      ).captured;
      final map = captured.first as Map<String, Object?>;
      expect(map['title'], 'New Resource Available');
      expect(map['is_read'], 0);
    });

    // ── getNotifications ──────────────────────────────────────────────────────
    test('getNotifications returns all notifications', () async {
      final notifs = [
        _sampleNotification(id: 'notif-001').toMap(),
        _sampleNotification(id: 'notif-002').toMap(),
      ];
      _stubQuery(db, notifs);

      final result = await repo.getNotifications();

      expect(result.length, 2);
    });

    test('getNotifications returns empty list when there are none', () async {
      _stubQuery(db, []);

      final result = await repo.getNotifications();

      expect(result, isEmpty);
    });

    // ── markAsRead ────────────────────────────────────────────────────────────
    test('markAsRead updates is_read flag', () async {
      _stubUpdate(db);

      await repo.markAsRead('notif-001');

      final captured = verify(
        () => db.update(
          'notifications',
          captureAny(),
          where: any(named: 'where'),
          whereArgs: any(named: 'whereArgs'),
        ),
      ).captured;
      final map = captured.first as Map<String, Object?>;
      expect(map['is_read'], 1);
    });

    // ── clearAll ──────────────────────────────────────────────────────────────
    test('clearAll removes all notifications', () async {
      _stubDelete(db);

      await repo.clearAll();

      verify(
        () => db.delete(
          'notifications',
          where: any(named: 'where'),
          whereArgs: any(named: 'whereArgs'),
        ),
      ).called(1);
    });
  });

  // --------------------------------------------------------------------------
  // MODEL SERIALISATION
  // --------------------------------------------------------------------------
  group('Model serialisation round-trips', () {
    test('UserModel toMap / fromMap round-trip', () {
      final user = _sampleUser();
      final restored = UserModel.fromMap(user.toMap());
      expect(restored.id, user.id);
      expect(restored.name, user.name);
      expect(restored.email, user.email);
      expect(restored.role, user.role);
      expect(restored.status, user.status);
    });

    test(
      'ResourceModel toMap / fromMap round-trip (booleans stored as ints)',
      () {
        final res = _sampleResource(
          isApproved: true,
          isBookmarked: true,
          isDownloaded: true,
        );
        final map = res.toMap();
        expect(map['isApproved'], 1);
        expect(map['isBookmarked'], 1);
        expect(map['isDownloaded'], 1);
        final restored = ResourceModel.fromMap(map);
        expect(restored.isApproved, isTrue);
        expect(restored.isBookmarked, isTrue);
        expect(restored.isDownloaded, isTrue);
        expect(restored.courseCode, 'MATH101');
      },
    );

    test('ResourceModel.empty() provides safe defaults', () {
      final empty = ResourceModel.empty('res-empty');
      expect(empty.id, 'res-empty');
      expect(empty.rating, 0.0);
      expect(empty.isApproved, isFalse);
    });

    test('ReviewModel toMap / fromMap round-trip', () {
      final review = _sampleReview();
      final restored = ReviewModel.fromMap(review.toMap());
      expect(restored.id, review.id);
      expect(restored.resourceId, review.resourceId);
      expect(restored.rating, review.rating);
      expect(restored.userName, review.userName);
    });

    test('RequestModel toMap / fromMap round-trip', () {
      final req = _sampleRequest();
      final restored = RequestModel.fromMap(req.toMap());
      expect(restored.id, req.id);
      expect(restored.courseCode, req.courseCode);
      expect(restored.status, req.status);
    });

    test('NotificationModel toMap / fromMap round-trip', () {
      final notif = _sampleNotification(isRead: true);
      final map = notif.toMap();
      expect(map['is_read'], 1);
      final restored = NotificationModel.fromMap(map);
      expect(restored.id, notif.id);
      expect(restored.isRead, isTrue);
    });

    test('UserModel.copyWith preserves unchanged fields', () {
      final user = _sampleUser();
      final copy = user.copyWith(name: 'Bob');
      expect(copy.name, 'Bob');
      expect(copy.email, user.email);
      expect(copy.role, user.role);
    });

    test('ResourceModel.copyWith preserves unchanged fields', () {
      final res = _sampleResource();
      final copy = res.copyWith(isApproved: true);
      expect(copy.isApproved, isTrue);
      expect(copy.title, res.title);
      expect(copy.uses, res.uses);
    });

    test('RequestModel.copyWith preserves unchanged fields', () {
      final req = _sampleRequest();
      final copy = req.copyWith(status: 'fulfilled');
      expect(copy.status, 'fulfilled');
      expect(copy.title, req.title);
    });
  });
}

// ─── ReviewModel.copyWith helper ─────────────────────────────────────────────
extension ReviewModelX on ReviewModel {
  ReviewModel copyWith({
    String? id,
    String? resourceId,
    String? userId,
    String? userName,
    double? rating,
    String? comment,
    String? time,
  }) {
    return ReviewModel(
      id: id ?? this.id,
      resourceId: resourceId ?? this.resourceId,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      rating: rating ?? this.rating,
      comment: comment ?? this.comment,
      time: time ?? this.time,
    );
  }
}
