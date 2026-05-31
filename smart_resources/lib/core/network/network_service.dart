import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../features/auth/data/models/user_model.dart';
import '../../features/requests/data/models/request_model.dart';
import '../../features/resources/data/models/resource_model.dart';
import '../../features/resources/data/models/review_model.dart';
import '../../features/home/domain/entities/activity.dart';

class NetworkService {
  NetworkService._();
  static final NetworkService instance = NetworkService._();

  static const String _base = 'http://192.168.8.150:3000';

  final _client = http.Client();

  Map<String, String> get _h => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  // Helpers

  Future<dynamic> _get(String path) async {
    final res = await _client
        .get(Uri.parse('$_base$path'), headers: _h)
        .timeout(const Duration(seconds: 10));
    return _parse(res);
  }

  Future<dynamic> _post(String path, Map<String, dynamic> body) async {
    final res = await _client
        .post(Uri.parse('$_base$path'), headers: _h, body: jsonEncode(body))
        .timeout(const Duration(seconds: 10));
    return _parse(res);
  }

  Future<dynamic> _put(String path, Map<String, dynamic> body) async {
    final res = await _client
        .put(Uri.parse('$_base$path'), headers: _h, body: jsonEncode(body))
        .timeout(const Duration(seconds: 10));
    return _parse(res);
  }

  Future<dynamic> _patch(String path) async {
    final res = await _client
        .patch(Uri.parse('$_base$path'), headers: _h)
        .timeout(const Duration(seconds: 10));
    return _parse(res);
  }

  Future<void> _delete(String path) async {
    final res = await _client
        .delete(Uri.parse('$_base$path'), headers: _h)
        .timeout(const Duration(seconds: 10));
    if (res.statusCode >= 400) {
      final b = res.body.isNotEmpty ? jsonDecode(res.body) : {};
      throw Exception(b['error'] ?? 'Request failed ${res.statusCode}');
    }
  }

  dynamic _parse(http.Response res) {
    if (res.statusCode >= 200 && res.statusCode < 300) {
      if (res.body.isEmpty) return null;
      return jsonDecode(res.body);
    }
    final b = res.body.isNotEmpty ? jsonDecode(res.body) : {};
    throw Exception(b['error'] ?? 'HTTP ${res.statusCode}');
  }

  // AUTH

  Future<UserModel?> authenticate(String email, String password) async {
    try {
      final data = await _post('/auth/login', {
        'email': email,
        'password': password,
      });
      return UserModel.fromMap(Map<String, Object?>.from(data as Map));
    } catch (_) {
      return null;
    }
  }

  Future<UserModel> register(UserModel user) async {
    final data = await _post('/auth/register', user.toMap());
    return UserModel.fromMap(Map<String, Object?>.from(data as Map));
  }

  // USERS

  Future<List<UserModel>> fetchUsers() async {
    final data = await _get('/users') as List;
    return data
        .map((u) => UserModel.fromMap(Map<String, Object?>.from(u as Map)))
        .toList();
  }

  Future<void> updateUser(UserModel user) async {
    await _put('/users/${user.id}', user.toMap());
  }

  Future<void> deleteUser(String id) async {
    await _delete('/users/$id');
  }

  // RESOURCES

  Future<List<ResourceModel>> fetchResources() async {
    final data = await _get('/resources') as List;
    return data
        .map((r) => ResourceModel.fromMap(Map<String, Object?>.from(r as Map)))
        .toList();
  }

  Future<ResourceModel?> fetchResourceById(String id) async {
    try {
      final data = await _get('/resources/$id');
      return ResourceModel.fromMap(Map<String, Object?>.from(data as Map));
    } catch (_) {
      return ResourceModel.empty(id);
    }
  }

  Future<ResourceModel> uploadResource(ResourceModel resource) async {
    final data = await _post('/resources', resource.toMap());
    return ResourceModel.fromMap(Map<String, Object?>.from(data as Map));
  }

  Future<void> updateResource(ResourceModel resource) async {
    await _put('/resources/${resource.id}', resource.toMap());
  }

  Future<void> approveResource(String id) async {
    await _patch('/resources/$id/approve');
  }

  Future<void> deleteResource(String id) async {
    await _delete('/resources/$id');
  }

  //  BOOKMARKS
  // Uses user_id / resource_id to match Flutter bookmarks table

  Future<List<ResourceModel>> fetchBookmarks(String userId) async {
    final data = await _get('/bookmarks/$userId') as List;
    return data
        .map((r) => ResourceModel.fromMap(Map<String, Object?>.from(r as Map)))
        .toList();
  }

  Future<void> addBookmark(String userId, String resourceId) async {
    await _post('/bookmarks', {'user_id': userId, 'resource_id': resourceId});
  }

  Future<void> removeBookmark(String userId, String resourceId) async {
    await _delete('/bookmarks/$userId/$resourceId');
  }

  //  REVIEWS

  Future<List<ReviewModel>> fetchReviews(String resourceId) async {
    final data = await _get('/reviews/$resourceId') as List;
    return data
        .map((r) => ReviewModel.fromMap(Map<String, Object?>.from(r as Map)))
        .toList();
  }

  Future<ReviewModel> addReview(ReviewModel review) async {
    final data = await _post('/reviews', review.toMap());
    return ReviewModel.fromMap(Map<String, Object?>.from(data as Map));
  }

  //  REQUESTS
  Future<List<RequestModel>> fetchRequests() async {
    final data = await _get('/requests') as List;
    return data
        .map((r) => RequestModel.fromMap(Map<String, Object?>.from(r as Map)))
        .toList();
  }

  Future<RequestModel> createRequest(RequestModel request) async {
    final data = await _post('/requests', request.toMap());
    return RequestModel.fromMap(Map<String, Object?>.from(data as Map));
  }

  Future<void> updateRequest(RequestModel request) async {
    await _put('/requests/${request.id}', request.toMap());
  }

  Future<RequestModel?> fulfillRequest(String id) async {
    try {
      final data = await _patch('/requests/$id/fulfill');
      return RequestModel.fromMap(Map<String, Object?>.from(data as Map));
    } catch (_) {
      return null;
    }
  }

  Future<void> deleteRequest(String id) async {
    await _delete('/requests/$id');
  }

  // ACTIVITIES

  Future<List<Activity>> fetchActivities({String? userId}) async {
    final path = userId != null ? '/activities?userId=$userId' : '/activities';
    final data = await _get(path) as List;
    return data
        .map(
          (a) => Activity(
            id: a['id'] ?? '',
            userId: a['userId'] ?? '',
            userName: a['userName'] ?? '',
            type: a['type'] ?? '',
            title: a['title'] ?? '',
            time: a['time'] ?? '',
            referenceId: a['referenceId'],
          ),
        )
        .toList();
  }

  Future<void> logActivity(Activity activity) async {
    await _post('/activities', {
      'id': activity.id,
      'userId': activity.userId,
      'userName': activity.userName,
      'type': activity.type,
      'title': activity.title,
      'time': activity.time,
      'referenceId': activity.referenceId,
    });
  }
}
