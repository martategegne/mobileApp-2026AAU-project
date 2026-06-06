import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:smart_resources/core/database/app_database.dart';
import 'package:smart_resources/core/network/network_service.dart';

import 'package:smart_resources/features/auth/data/models/user_model.dart';
import 'package:smart_resources/features/auth/data/repositories/auth_repository_impl.dart';

import 'package:smart_resources/features/resources/data/models/resource_model.dart';
import 'package:smart_resources/features/resources/data/models/review_model.dart';
import 'package:smart_resources/features/resources/data/repositories/resource_repository_impl.dart';
import 'package:smart_resources/features/resources/domain/entities/review.dart';

import 'package:smart_resources/features/requests/data/models/request_model.dart';
import 'package:smart_resources/features/requests/data/repositories/request_repository_impl.dart';
import 'package:smart_resources/features/requests/domain/entities/request.dart';

import 'package:smart_resources/features/notifications/data/models/notification_model.dart';
import 'package:smart_resources/features/notifications/data/repositories/notification_repository_impl.dart';
import 'package:smart_resources/features/notifications/domain/entities/notification.dart';

import 'package:smart_resources/features/home/domain/entities/activity.dart';

// ─── Mockito generated mocks ──────────────────────────────────────────────────
@GenerateMocks([NetworkService])
import 'integration_test.mocks.dart';

// ─── Helpers ──────────────────────────────────────────────────────────────────

Future<Database> _openTestDb() async {
  sqfliteFfiInit();
  final factory = databaseFactoryFfi;
  final db = await factory.openDatabase(
    inMemoryDatabasePath,
    options: OpenDatabaseOptions(
      version: 1,
      onCreate: (db, _) async {
        await db.execute('''
          CREATE TABLE users(
            id TEXT PRIMARY KEY,
            name TEXT,
            email TEXT UNIQUE,
            password TEXT,
            role TEXT,
            status TEXT
          )
        ''');
        await db.execute('''
          CREATE TABLE resources(
            id TEXT PRIMARY KEY,
            title TEXT,
            description TEXT,
            courseCode TEXT,
            rating REAL,
            reviewCount INTEGER,
            uses INTEGER,
            fileType TEXT,
            uploader TEXT,
            isApproved INTEGER,
            isBookmarked INTEGER,
            isDownloaded INTEGER,
            file_path TEXT
          )
        ''');
        await db.execute('''
          CREATE TABLE requests(
            id TEXT PRIMARY KEY,
            title TEXT,
            description TEXT,
            courseCode TEXT,
            requestedBy TEXT,
            time TEXT,
            status TEXT
          )
        ''');
        await db.execute('''
          CREATE TABLE bookmarks(
            user_id TEXT,
            resource_id TEXT,
            PRIMARY KEY(user_id, resource_id)
          )
        ''');
        await db.execute('''
          CREATE TABLE reviews(
            id TEXT PRIMARY KEY,
            resource_id TEXT,
            user_id TEXT,
            user_name TEXT,
            rating REAL,
            comment TEXT,
            time TEXT
          )
        ''');
        await db.execute('''
          CREATE TABLE activities(
            id TEXT PRIMARY KEY,
            user_id TEXT,
            user_name TEXT,
            type TEXT,
            title TEXT,
            time TEXT,
            reference_id TEXT
          )
        ''');
        await db.execute('''
          CREATE TABLE notifications(
            id TEXT PRIMARY KEY,
            title TEXT,
            message TEXT,
            time TEXT,
            is_read INTEGER
          )
        ''');
      },
    ),
  );
  return db;
}

AppDatabase _wrapDb(Database raw) {
  return _TestAppDatabase(raw);
}

class _TestAppDatabase extends AppDatabase {
  _TestAppDatabase(this._raw) : super.test();
  final Database _raw;

  @override
  Future<Database> get database async => _raw;
}

// ─── Sample fixtures ──────────────────────────────────────────────────────────

UserModel _sampleUser({
  String id = 'user-001',
  String name = 'Alice',
  String email = 'alice@test.com',
  String password = 'pass123',
  String role = 'User',
  String status = 'active',
}) =>
    UserModel(
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
}) =>
    ResourceModel(
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

RequestModel _sampleRequest({
  String id = 'req-001',
  String status = 'open',
}) =>
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
}) =>
    NotificationModel(
      id: id,
      title: 'New Resource Available',
      message: 'Calculus Notes have been approved.',
      time: '2024-01-15T12:00:00Z',
      isRead: isRead,
    );

// ══════════════════════════════════════════════════════════════════════════════
//  TESTS
// ══════════════════════════════════════════════════════════════════════════════

void main() {
  // --------------------------------------------------------------------------
  // AUTH REPOSITORY
  // --------------------------------------------------------------------------
  group('AuthRepositoryImpl', () {
    late Database rawDb;
    late AppDatabase db;
    late MockNetworkService mockNet;
    late AuthRepositoryImpl repo;

    setUp(() async {
      rawDb = await _openTestDb();
      db = _wrapDb(rawDb);
      mockNet = MockNetworkService();
      repo = AuthRepositoryImpl(database: db, network: mockNet);
    });

    tearDown(() async => rawDb.close());

    // ── login ────────────────────────────────────────────────────────────────

    test('login returns cached user when present in SQLite', () async {
      final user = _sampleUser();
      await rawDb.insert('users', user.toMap());

      final result = await repo.login(user.email, user.password);

      verifyNever(mockNet.authenticate(any, any));
      expect(result.id, user.id);
      expect(result.name, user.name);
    });

    test('login hits network when cache is empty and stores result', () async {
      final user = _sampleUser();
      when(mockNet.authenticate(user.email, user.password))
          .thenAnswer((_) async => user);

      final result = await repo.login(user.email, user.password);

      verify(mockNet.authenticate(user.email, user.password)).called(1);
      expect(result.id, user.id);

      // Verify persisted locally
      final rows = await rawDb.query('users',
          where: 'email = ?', whereArgs: [user.email]);
      expect(rows, isNotEmpty);
    });

    test('login throws AuthException on bad credentials', () async {
      when(mockNet.authenticate(any, any)).thenAnswer((_) async => null);

      expect(
        () => repo.login('bad@test.com', 'wrong'),
        throwsA(isA<AuthException>()),
      );
    });

    // ── signup ───────────────────────────────────────────────────────────────

    test('signup registers user locally and on network', () async {
      final user = _sampleUser();
      when(mockNet.register(any)).thenAnswer((_) async => user);

      final result =
          await repo.signup(user.name, user.email, user.password);

      verify(mockNet.register(any)).called(1);
      expect(result.email, user.email);

      final rows = await rawDb.query('users',
          where: 'email = ?', whereArgs: [user.email]);
      expect(rows, isNotEmpty);
    });

    // ── updateProfile ─────────────────────────────────────────────────────────

    test('updateProfile updates SQLite and syncs to network', () async {
      final user = _sampleUser();
      await rawDb.insert('users', user.toMap());
      when(mockNet.updateUser(any)).thenAnswer((_) async {});

      final updated = await repo.updateProfile(
          user.id, 'Alice Updated', 'alice2@test.com', 'newpass');

      verify(mockNet.updateUser(any)).called(1);
      expect(updated.name, 'Alice Updated');
      expect(updated.email, 'alice2@test.com');

      final rows = await rawDb.query('users',
          where: 'id = ?', whereArgs: [user.id]);
      expect(rows.first['name'], 'Alice Updated');
    });

    test('updateProfile throws AuthException when user not in cache', () async {
      expect(
        () => repo.updateProfile('non-existent', 'X', 'x@x.com', 'x'),
        throwsA(isA<AuthException>()),
      );
    });

    // ── getUsers ──────────────────────────────────────────────────────────────

    test('getUsers returns cached list without network call', () async {
      await rawDb.insert('users', _sampleUser().toMap());

      final users = await repo.getUsers();

      verifyNever(mockNet.fetchUsers());
      expect(users.length, 1);
    });

    test('getUsers fetches from network when cache is empty', () async {
      final remoteUsers = [_sampleUser(), _sampleUser(id: 'user-002', email: 'bob@test.com')];
      when(mockNet.fetchUsers()).thenAnswer((_) async => remoteUsers);

      final users = await repo.getUsers();

      verify(mockNet.fetchUsers()).called(1);
      expect(users.length, 2);

      final rows = await rawDb.query('users');
      expect(rows.length, 2);
    });

    // ── toggleUserStatus ──────────────────────────────────────────────────────

    test('toggleUserStatus suspends active user locally and on network',
        () async {
      final user = _sampleUser(status: 'active');
      await rawDb.insert('users', user.toMap());
      when(mockNet.updateUser(any)).thenAnswer((_) async {});

      await repo.toggleUserStatus(user.id);

      verify(mockNet.updateUser(any)).called(1);
      final rows = await rawDb.query('users',
          where: 'id = ?', whereArgs: [user.id]);
      expect(rows.first['status'], 'suspended');
    });

    test('toggleUserStatus re-activates suspended user', () async {
      final user = _sampleUser(status: 'suspended');
      await rawDb.insert('users', user.toMap());
      when(mockNet.updateUser(any)).thenAnswer((_) async {});

      await repo.toggleUserStatus(user.id);

      final rows = await rawDb.query('users',
          where: 'id = ?', whereArgs: [user.id]);
      expect(rows.first['status'], 'active');
    });

    // ── deleteUser ────────────────────────────────────────────────────────────

    test('deleteUser removes from SQLite and calls network', () async {
      final user = _sampleUser();
      await rawDb.insert('users', user.toMap());
      when(mockNet.deleteUser(user.id)).thenAnswer((_) async {});

      await repo.deleteUser(user.id);

      verify(mockNet.deleteUser(user.id)).called(1);
      final rows = await rawDb.query('users',
          where: 'id = ?', whereArgs: [user.id]);
      expect(rows, isEmpty);
    });
  });

  // --------------------------------------------------------------------------
  // RESOURCE REPOSITORY
  // --------------------------------------------------------------------------
  group('ResourceRepositoryImpl', () {
    late Database rawDb;
    late AppDatabase db;
    late MockNetworkService mockNet;
    late ResourceRepositoryImpl repo;

    setUp(() async {
      rawDb = await _openTestDb();
      db = _wrapDb(rawDb);
      mockNet = MockNetworkService();
      repo = ResourceRepositoryImpl(database: db, network: mockNet);
    });

    tearDown(() async => rawDb.close());

    // ── getResources ──────────────────────────────────────────────────────────

    test('getResources returns cached resources without network call', () async {
      await rawDb.insert('resources', _sampleResource().toMap());

      final resources = await repo.getResources();

      verifyNever(mockNet.fetchResources());
      expect(resources.length, 1);
      expect(resources.first.title, 'Calculus Notes');
    });

    test('getResources fetches from network when cache is empty', () async {
      final remote = [_sampleResource(), _sampleResource(id: 'res-002', title: 'Physics Notes')];
      when(mockNet.fetchResources()).thenAnswer((_) async => remote);

      final resources = await repo.getResources();

      verify(mockNet.fetchResources()).called(1);
      expect(resources.length, 2);

      final rows = await rawDb.query('resources');
      expect(rows.length, 2);
    });

    // ── getResourceById ───────────────────────────────────────────────────────

    test('getResourceById returns cached resource', () async {
      final res = _sampleResource();
      await rawDb.insert('resources', res.toMap());

      final result = await repo.getResourceById(res.id);

      verifyNever(mockNet.fetchResourceById(any));
      expect(result?.id, res.id);
    });

    test('getResourceById fetches from network on cache miss', () async {
      final res = _sampleResource();
      when(mockNet.fetchResourceById(res.id)).thenAnswer((_) async => res);

      final result = await repo.getResourceById(res.id);

      verify(mockNet.fetchResourceById(res.id)).called(1);
      expect(result?.id, res.id);

      final rows = await rawDb.query('resources',
          where: 'id = ?', whereArgs: [res.id]);
      expect(rows, isNotEmpty);
    });

    // ── uploadResource ────────────────────────────────────────────────────────

    test('uploadResource posts to network and caches locally', () async {
      final res = _sampleResource();
      when(mockNet.uploadResource(any)).thenAnswer((_) async => res);

      await repo.uploadResource(res);

      verify(mockNet.uploadResource(any)).called(1);
      final rows = await rawDb.query('resources',
          where: 'id = ?', whereArgs: [res.id]);
      expect(rows, isNotEmpty);
    });

    // ── updateResource ────────────────────────────────────────────────────────

    test('updateResource updates local SQLite cache', () async {
      final res = _sampleResource();
      await rawDb.insert('resources', res.toMap());

      final updated = res.copyWith(title: 'Updated Calculus Notes');
      await repo.updateResource(updated);

      final rows = await rawDb.query('resources',
          where: 'id = ?', whereArgs: [res.id]);
      expect(rows.first['title'], 'Updated Calculus Notes');
    });

    // ── bookmarkResource ──────────────────────────────────────────────────────

    test('bookmarkResource adds bookmark locally and on network', () async {
      final res = _sampleResource();
      await rawDb.insert('resources', res.toMap());
      when(mockNet.addBookmark(any, any)).thenAnswer((_) async {});

      await repo.bookmarkResource('user-001', res.id, true);

      verify(mockNet.addBookmark('user-001', res.id)).called(1);
      final bRows = await rawDb.query('bookmarks');
      expect(bRows, isNotEmpty);

      final rRows = await rawDb.query('resources',
          where: 'id = ?', whereArgs: [res.id]);
      expect(rRows.first['isBookmarked'], 1);
    });

    test('bookmarkResource removes bookmark locally and on network', () async {
      final res = _sampleResource(isBookmarked: true);
      await rawDb.insert('resources', res.toMap());
      await rawDb.insert('bookmarks', {
        'user_id': 'user-001',
        'resource_id': res.id,
      });
      when(mockNet.removeBookmark(any, any)).thenAnswer((_) async {});

      await repo.bookmarkResource('user-001', res.id, false);

      verify(mockNet.removeBookmark('user-001', res.id)).called(1);
      final bRows = await rawDb.query('bookmarks');
      expect(bRows, isEmpty);

      final rRows = await rawDb.query('resources',
          where: 'id = ?', whereArgs: [res.id]);
      expect(rRows.first['isBookmarked'], 0);
    });

    // ── markDownloaded ────────────────────────────────────────────────────────

    test('markDownloaded sets isDownloaded flag and increments uses', () async {
      final res = _sampleResource();
      await rawDb.insert('resources', res.toMap());

      await repo.markDownloaded(res.id);

      final rows = await rawDb.query('resources',
          where: 'id = ?', whereArgs: [res.id]);
      expect(rows.first['isDownloaded'], 1);
      expect(rows.first['uses'], greaterThan(res.uses));
    });

    // ── getBookmarkedResources ────────────────────────────────────────────────

    test('getBookmarkedResources returns only bookmarked resources', () async {
      final res1 = _sampleResource(id: 'res-001');
      final res2 = _sampleResource(id: 'res-002', title: 'Physics Notes');
      await rawDb.insert('resources', res1.toMap());
      await rawDb.insert('resources', res2.toMap());
      await rawDb.insert('bookmarks', {
        'user_id': 'user-001',
        'resource_id': 'res-001',
      });

      final bookmarked = await repo.getBookmarkedResources('user-001');

      expect(bookmarked.length, 1);
      expect(bookmarked.first.id, 'res-001');
      expect(bookmarked.first.isBookmarked, isTrue);
    });

    test('getBookmarkedResources returns empty list when no bookmarks', () async {
      final resources = await repo.getBookmarkedResources('user-001');
      expect(resources, isEmpty);
    });

    // ── getDownloadedResources ────────────────────────────────────────────────

    test('getDownloadedResources returns only downloaded resources', () async {
      final downloaded = _sampleResource(id: 'res-001', isDownloaded: true);
      final notDownloaded = _sampleResource(id: 'res-002', title: 'Physics Notes');
      await rawDb.insert('resources', downloaded.toMap());
      await rawDb.insert('resources', notDownloaded.toMap());

      final results = await repo.getDownloadedResources();

      expect(results.length, 1);
      expect(results.first.id, 'res-001');
    });

    // ── approveResource ───────────────────────────────────────────────────────

    test('approveResource updates backend and local cache', () async {
      final res = _sampleResource(isApproved: false);
      await rawDb.insert('resources', res.toMap());
      when(mockNet.approveResource(res.id)).thenAnswer((_) async {});

      await repo.approveResource(res.id);

      verify(mockNet.approveResource(res.id)).called(1);
      final rows = await rawDb.query('resources',
          where: 'id = ?', whereArgs: [res.id]);
      expect(rows.first['isApproved'], 1);
    });

    // ── deleteResource ────────────────────────────────────────────────────────

    test('deleteResource removes resource and related bookmarks/reviews', () async {
      final res = _sampleResource();
      await rawDb.insert('resources', res.toMap());
      await rawDb.insert('bookmarks', {
        'user_id': 'user-001',
        'resource_id': res.id,
      });
      await rawDb.insert('reviews', _sampleReview().toMap());
      when(mockNet.deleteResource(res.id)).thenAnswer((_) async {});

      await repo.deleteResource(res.id);

      verify(mockNet.deleteResource(res.id)).called(1);
      expect(await rawDb.query('resources', where: 'id = ?', whereArgs: [res.id]), isEmpty);
      expect(await rawDb.query('bookmarks'), isEmpty);
      expect(await rawDb.query('reviews'), isEmpty);
    });

    // ── addReview ─────────────────────────────────────────────────────────────

    test('addReview saves to backend and local cache, updates resource rating',
        () async {
      final res = _sampleResource();
      await rawDb.insert('resources', res.toMap());
      final review = _sampleReview();
      when(mockNet.addReview(any)).thenAnswer((_) async => review);

      await repo.addReview(review);

      verify(mockNet.addReview(any)).called(1);
      final reviewRows = await rawDb.query('reviews');
      expect(reviewRows, isNotEmpty);

      final resRows = await rawDb.query('resources',
          where: 'id = ?', whereArgs: [res.id]);
      expect((resRows.first['reviewCount'] as int), greaterThan(res.reviewCount));
    });

    // ── getReviewsForResource ─────────────────────────────────────────────────

    test('getReviewsForResource returns correct reviews', () async {
      final review = _sampleReview();
      await rawDb.insert('reviews', review.toMap());

      final reviews = await repo.getReviewsForResource('res-001');

      expect(reviews.length, 1);
      expect(reviews.first.comment, 'Excellent resource!');
    });

    // ── getUserReviewCount ────────────────────────────────────────────────────

    test('getUserReviewCount returns correct count', () async {
      await rawDb.insert('reviews', _sampleReview(resourceId: 'res-001').toMap());
      await rawDb.insert('reviews',
          _sampleReview(resourceId: 'res-002').copyWith(id: 'rev-002').toMap());

      final count = await repo.getUserReviewCount('user-001');

      expect(count, 2);
    });
  });

  // --------------------------------------------------------------------------
  // REQUEST REPOSITORY
  // --------------------------------------------------------------------------
  group('RequestRepositoryImpl', () {
    late Database rawDb;
    late AppDatabase db;
    late MockNetworkService mockNet;
    late RequestRepositoryImpl repo;

    setUp(() async {
      rawDb = await _openTestDb();
      db = _wrapDb(rawDb);
      mockNet = MockNetworkService();
      repo = RequestRepositoryImpl(database: db, network: mockNet);
    });

    tearDown(() async => rawDb.close());

    // ── getRequests ───────────────────────────────────────────────────────────

    test('getRequests returns cached requests', () async {
      await rawDb.insert('requests', _sampleRequest().toMap());

      final requests = await repo.getRequests();

      verifyNever(mockNet.fetchRequests());
      expect(requests.length, 1);
    });

    test('getRequests fetches from network on cache miss', () async {
      final remote = [_sampleRequest(), _sampleRequest(id: 'req-002')];
      when(mockNet.fetchRequests()).thenAnswer((_) async => remote);

      final requests = await repo.getRequests();

      verify(mockNet.fetchRequests()).called(1);
      expect(requests.length, 2);
    });

    // ── createRequest ─────────────────────────────────────────────────────────

    test('createRequest posts to network and caches locally', () async {
      final req = _sampleRequest();
      when(mockNet.createRequest(any)).thenAnswer((_) async => req);

      await repo.createRequest(req);

      verify(mockNet.createRequest(any)).called(1);
      final rows = await rawDb.query('requests',
          where: 'id = ?', whereArgs: [req.id]);
      expect(rows, isNotEmpty);
    });

    // ── updateRequest ─────────────────────────────────────────────────────────

    test('updateRequest syncs to network and updates local SQLite', () async {
      final req = _sampleRequest();
      await rawDb.insert('requests', req.toMap());
      when(mockNet.updateRequest(any)).thenAnswer((_) async {});

      final updated = req.copyWith(title: 'Updated Title');
      await repo.updateRequest(updated);

      verify(mockNet.updateRequest(any)).called(1);
      final rows = await rawDb.query('requests',
          where: 'id = ?', whereArgs: [req.id]);
      expect(rows.first['title'], 'Updated Title');
    });

    // ── deleteRequest ─────────────────────────────────────────────────────────

    test('deleteRequest removes from network and local SQLite', () async {
      final req = _sampleRequest();
      await rawDb.insert('requests', req.toMap());
      when(mockNet.deleteRequest(req.id)).thenAnswer((_) async {});

      await repo.deleteRequest(req.id);

      verify(mockNet.deleteRequest(req.id)).called(1);
      final rows = await rawDb.query('requests',
          where: 'id = ?', whereArgs: [req.id]);
      expect(rows, isEmpty);
    });

    // ── fulfillRequest ────────────────────────────────────────────────────────

    test('fulfillRequest updates status in backend and local cache', () async {
      final req = _sampleRequest(status: 'open');
      await rawDb.insert('requests', req.toMap());
      final fulfilled = req.copyWith(status: 'fulfilled');
      when(mockNet.fulfillRequest(req.id))
          .thenAnswer((_) async => fulfilled);

      await repo.fulfillRequest(req.id);

      verify(mockNet.fulfillRequest(req.id)).called(1);
      final rows = await rawDb.query('requests',
          where: 'id = ?', whereArgs: [req.id]);
      expect(rows.first['status'], 'fulfilled');
    });

    test('fulfillRequest is a no-op when network returns null', () async {
      when(mockNet.fulfillRequest('missing-id'))
          .thenAnswer((_) async => null);

      // Should not throw
      await repo.fulfillRequest('missing-id');
    });
  });

  // --------------------------------------------------------------------------
  // NOTIFICATION REPOSITORY
  // --------------------------------------------------------------------------
  group('NotificationRepositoryImpl', () {
    late Database rawDb;
    late AppDatabase db;
    late NotificationRepositoryImpl repo;

    setUp(() async {
      rawDb = await _openTestDb();
      db = _wrapDb(rawDb);
      repo = NotificationRepositoryImpl(database: db);
    });

    tearDown(() async => rawDb.close());

    // ── addNotification ───────────────────────────────────────────────────────

    test('addNotification persists notification', () async {
      final notif = _sampleNotification();
      await repo.addNotification(notif);

      final rows = await rawDb.query('notifications');
      expect(rows.length, 1);
      expect(rows.first['title'], 'New Resource Available');
      expect(rows.first['is_read'], 0);
    });

    // ── getNotifications ──────────────────────────────────────────────────────

    test('getNotifications returns all notifications ordered by time DESC',
        () async {
      await rawDb.insert('notifications',
          _sampleNotification(id: 'notif-001').copyWith(time: '2024-01-10').toMap());
      await rawDb.insert('notifications',
          _sampleNotification(id: 'notif-002').copyWith(time: '2024-01-15').toMap());

      final notifs = await repo.getNotifications();

      expect(notifs.length, 2);
      // Most recent first
      expect(notifs.first.id, 'notif-002');
    });

    test('getNotifications returns empty list when there are none', () async {
      final notifs = await repo.getNotifications();
      expect(notifs, isEmpty);
    });

    // ── markAsRead ────────────────────────────────────────────────────────────

    test('markAsRead updates is_read flag in SQLite', () async {
      final notif = _sampleNotification(isRead: false);
      await rawDb.insert('notifications', notif.toMap());

      await repo.markAsRead(notif.id);

      final rows = await rawDb.query('notifications',
          where: 'id = ?', whereArgs: [notif.id]);
      expect(rows.first['is_read'], 1);
    });

    // ── clearAll ──────────────────────────────────────────────────────────────

    test('clearAll removes all notifications', () async {
      await rawDb.insert(
          'notifications', _sampleNotification(id: 'notif-001').toMap());
      await rawDb.insert(
          'notifications', _sampleNotification(id: 'notif-002').toMap());

      await repo.clearAll();

      final rows = await rawDb.query('notifications');
      expect(rows, isEmpty);
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

    test('ResourceModel toMap / fromMap round-trip (booleans stored as ints)',
        () {
      final res = _sampleResource(isApproved: true, isBookmarked: true, isDownloaded: true);
      final map = res.toMap();
      expect(map['isApproved'], 1);
      expect(map['isBookmarked'], 1);
      expect(map['isDownloaded'], 1);

      final restored = ResourceModel.fromMap(map);
      expect(restored.isApproved, isTrue);
      expect(restored.isBookmarked, isTrue);
      expect(restored.isDownloaded, isTrue);
      expect(restored.courseCode, 'MATH101');
    });

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

// ─── ReviewModel.copyWith helper (not in generated model) ────────────────────
// Add this extension to make the test compile without modifying production code.
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

extension NotificationModelX on NotificationModel {
  NotificationModel copyWith({
    String? id,
    String? title,
    String? message,
    String? time,
    bool? isRead,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      time: time ?? this.time,
      isRead: isRead ?? this.isRead,
    );
  }
}
