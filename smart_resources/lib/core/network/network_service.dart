import 'dart:async';
import '../../features/auth/data/models/user_model.dart';
import '../../features/requests/data/models/request_model.dart';
import '../../features/resources/data/models/resource_model.dart';

class NetworkService {
  NetworkService._();
  static final NetworkService instance = NetworkService._();

  final List<UserModel> _users = [
    const UserModel(
      id: 'admin-1',
      name: 'Admin User',
      email: 'admin@studysphere.com',
      password: 'admin123',
      role: 'Admin',
      status: 'active',
    ),
    const UserModel(
      id: 'student-1',
      name: 'Anatoli Chala',
      email: 'student@studysphere.com',
      password: 'student123',
      role: 'User',
      status: 'active',
    ),
  ];

  // Removed default resources
  final List<ResourceModel> _resources = [];

  // Removed default requests
  final List<RequestModel> _requests = [];

  Future<List<UserModel>> fetchUsers() async {
    await Future.delayed(const Duration(milliseconds: 400));
    return List<UserModel>.from(_users);
  }

  Future<UserModel?> authenticate(String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 400));
    try {
      return _users.firstWhere((user) => user.email == email && user.password == password);
    } catch (_) { return null; }
  }

  Future<UserModel> register(UserModel user) async {
    await Future.delayed(const Duration(milliseconds: 400));
    _users.add(user);
    return user;
  }

  Future<void> updateUser(UserModel user) async {
    final index = _users.indexWhere((u) => u.id == user.id);
    if (index != -1) _users[index] = user;
  }

  Future<void> deleteUser(String id) async {
    await Future.delayed(const Duration(milliseconds: 400));
    _users.removeWhere((user) => user.id == id);
  }

  Future<List<ResourceModel>> fetchResources() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return List<ResourceModel>.from(_resources);
  }

  Future<ResourceModel?> fetchResourceById(String id) async {
    await Future.delayed(const Duration(milliseconds: 400));
    try {
      return _resources.firstWhere((r) => r.id == id);
    } catch (_) { return ResourceModel.empty(id); }
  }

  Future<ResourceModel> uploadResource(ResourceModel resource) async {
    await Future.delayed(const Duration(milliseconds: 500));
    _resources.add(resource);
    return resource;
  }

  Future<void> deleteResource(String id) async {
    _resources.removeWhere((r) => r.id == id);
  }

  Future<List<RequestModel>> fetchRequests() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return List<RequestModel>.from(_requests);
  }

  Future<RequestModel> createRequest(RequestModel request) async {
    await Future.delayed(const Duration(milliseconds: 500));
    _requests.add(request);
    return request;
  }

  Future<void> deleteRequest(String id) async {
    _requests.removeWhere((r) => r.id == id);
  }

  Future<RequestModel?> fulfillRequest(String id) async {
    await Future.delayed(const Duration(milliseconds: 400));
    final index = _requests.indexWhere((r) => r.id == id);
    if (index < 0) return null;
    _requests[index] = _requests[index].copyWith(status: 'fulfilled');
    return _requests[index];
  }
}
