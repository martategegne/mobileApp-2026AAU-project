class Resource {
  final String id;
  final String title;
  final String description;
  final String courseCode;
  final double rating;
  final int reviewCount;
  final int uses;
  final String fileType;
  final String uploader;
  final bool isApproved;
  final bool isBookmarked;
  final bool isDownloaded;
  final String? filePath;

  const Resource({
    required this.id,
    required this.title,
    required this.description,
    required this.courseCode,
    required this.rating,
    required this.reviewCount,
    required this.uses,
    required this.fileType,
    required this.uploader,
    required this.isApproved,
    required this.isBookmarked,
    required this.isDownloaded,
    this.filePath,
  });

  bool get isActive => isApproved;
}
