import '../../../../core/database/app_database.dart';
import '../../../../core/network/network_service.dart';
import '../../domain/entities/request.dart';
import '../../domain/repositories/request_repository.dart';
import '../models/request_model.dart';

class RequestRepositoryImpl implements RequestRepository {
  RequestRepositoryImpl({required this.database, required this.network});

  final AppDatabase database;
  final NetworkService network;

  Future<List<RequestModel>> _fetchLocalRequests() async {
    final rows = await database.query('requests');
    return rows.map((row) => RequestModel.fromMap(row)).toList();
  }

  @override
  Future<List<Request>> getRequests() async {
    final local = await _fetchLocalRequests();
    if (local.isNotEmpty) {
      return local;
    }
    final remote = await network.fetchRequests();
    for (final request in remote) {
      await database.insert('requests', request.toMap());
    }
    return remote;
  }

  @override
  Future<Request> createRequest(Request request) async {
    final remote = await network.createRequest(RequestModel(
      id: request.id,
      title: request.title,
      description: request.description,
      courseCode: request.courseCode,
      requestedBy: request.requestedBy,
      time: request.time,
      status: request.status,
    ));
    await database.insert('requests', (remote as RequestModel).toMap());
    return remote;
  }

  @override
  Future<void> updateRequest(Request request) async {
    final model = RequestModel(
      id: request.id,
      title: request.title,
      description: request.description,
      courseCode: request.courseCode,
      requestedBy: request.requestedBy,
      time: request.time,
      status: request.status,
    );
    await database.update(
      'requests',
      model.toMap(),
      where: 'id = ?',
      whereArgs: [request.id],
    );
  }

  @override
  Future<void> deleteRequest(String id) async {
    await database.delete('requests', where: 'id = ?', whereArgs: [id]);
  }

  @override
  Future<void> fulfillRequest(String id) async {
    final remote = await network.fulfillRequest(id);
    if (remote == null) return;
    await database.update(
      'requests',
      remote.toMap(),
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
