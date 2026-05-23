class Activity {
  final String id;
  final String userId;
  final String userName;
  final String type; // 'upload', 'request', 'review', 'bookmark', 'download', 'signup', 'profile_update'
  final String title;
  final String time;
  final String? referenceId;

  const Activity({
    required this.id,
    required this.userId,
    required this.userName,
    required this.type,
    required this.title,
    required this.time,
    this.referenceId,
  });
}
