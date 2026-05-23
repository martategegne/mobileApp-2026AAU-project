import '../../domain/entities/request.dart';

class RequestModel extends Request {
  const RequestModel({
    required super.id,
    required super.title,
    required super.description,
    required super.courseCode,
    required super.requestedBy,
    required super.time,
    required super.status,
  });

  factory RequestModel.fromMap(Map<String, Object?> map) {
    return RequestModel(
      id: (map['id'] as String?) ?? '',
      title: (map['title'] as String?) ?? 'No Title',
      description: (map['description'] as String?) ?? '',
      courseCode: (map['courseCode'] as String?) ?? 'N/A',
      requestedBy: (map['requestedBy'] as String?) ?? 'Unknown',
      time: (map['time'] as String?) ?? '',
      status: (map['status'] as String?) ?? 'open',
    );
  }

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'courseCode': courseCode,
      'requestedBy': requestedBy,
      'time': time,
      'status': status,
    };
  }

  RequestModel copyWith({
    String? id,
    String? title,
    String? description,
    String? courseCode,
    String? requestedBy,
    String? time,
    String? status,
  }) {
    return RequestModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      courseCode: courseCode ?? this.courseCode,
      requestedBy: requestedBy ?? this.requestedBy,
      time: time ?? this.time,
      status: status ?? this.status,
    );
  }
}
