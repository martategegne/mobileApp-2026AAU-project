class Request {
  final String id;
  final String title;
  final String description;
  final String courseCode;
  final String requestedBy;
  final String time;
  final String status;

  const Request({
    required this.id,
    required this.title,
    required this.description,
    required this.courseCode,
    required this.requestedBy,
    required this.time,
    required this.status,
  });
}
