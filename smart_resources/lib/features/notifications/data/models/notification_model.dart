import '../../domain/entities/notification.dart';

class NotificationModel extends AppNotification {
  const NotificationModel({
    required super.id,
    required super.title,
    required super.message,
    required super.time,
    super.isRead,
  });

  factory NotificationModel.fromMap(Map<String, Object?> map) {
    return NotificationModel(
      id: map['id'] as String,
      title: map['title'] as String,
      message: map['message'] as String,
      time: map['time'] as String,
      isRead: (map['is_read'] as int) == 1,
    );
  }

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'title': title,
      'message': message,
      'time': time,
      'is_read': isRead ? 1 : 0,
    };
  }

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
