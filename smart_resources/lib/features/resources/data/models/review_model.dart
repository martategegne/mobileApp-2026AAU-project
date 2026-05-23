import '../../domain/entities/review.dart';

class ReviewModel extends Review {
  const ReviewModel({
    required super.id,
    required super.resourceId,
    required super.userId,
    required super.userName,
    required super.rating,
    required super.comment,
    required super.time,
  });

  factory ReviewModel.fromMap(Map<String, Object?> map) {
    return ReviewModel(
      id: (map['id'] as String?) ?? '',
      resourceId: (map['resource_id'] as String?) ?? '',
      userId: (map['user_id'] as String?) ?? '',
      userName: (map['user_name'] as String?) ?? 'Anonymous',
      rating: (map['rating'] as num?)?.toDouble() ?? 0.0,
      comment: (map['comment'] as String?) ?? '',
      time: (map['time'] as String?) ?? '',
    );
  }

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'resource_id': resourceId,
      'user_id': userId,
      'user_name': userName,
      'rating': rating,
      'comment': comment,
      'time': time,
    };
  }
}
