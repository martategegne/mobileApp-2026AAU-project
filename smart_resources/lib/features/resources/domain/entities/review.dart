class Review {
  final String id;
  final String resourceId;
  final String userId;
  final String userName;
  final double rating;
  final String comment;
  final String time;

  const Review({
    required this.id,
    required this.resourceId,
    required this.userId,
    required this.userName,
    required this.rating,
    required this.comment,
    required this.time,
  });
}
