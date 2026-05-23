import '../../domain/entities/activity.dart';

class ActivityModel extends Activity {
  const ActivityModel({
    required super.id,
    required super.userId,
    required super.userName,
    required super.type,
    required super.title,
    required super.time,
    super.referenceId,
  });

  factory ActivityModel.fromMap(Map<String, Object?> map) {
    return ActivityModel(
      id: map['id'] as String,
      userId: map['user_id'] as String,
      userName: map['user_name'] as String? ?? 'User',
      type: map['type'] as String,
      title: map['title'] as String,
      time: map['time'] as String,
      referenceId: map['reference_id'] as String?,
    );
  }

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'user_name': userName,
      'type': type,
      'title': title,
      'time': time,
      'reference_id': referenceId,
    };
  }
}
