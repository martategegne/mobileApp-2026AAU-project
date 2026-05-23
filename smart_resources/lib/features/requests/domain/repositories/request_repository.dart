import '../entities/request.dart';

abstract class RequestRepository {
  Future<List<Request>> getRequests();

  Future<Request> createRequest(Request request);

  Future<void> updateRequest(Request request);

  Future<void> deleteRequest(String id);

  Future<void> fulfillRequest(String id);
}
