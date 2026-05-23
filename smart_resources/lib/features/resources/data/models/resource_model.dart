import '../../domain/entities/resource.dart';

class ResourceModel extends Resource {
  const ResourceModel({
    required super.id,
    required super.title,
    required super.description,
    required super.courseCode,
    required super.rating,
    required super.reviewCount,
    required super.uses,
    required super.fileType,
    required super.uploader,
    required super.isApproved,
    required super.isBookmarked,
    required super.isDownloaded,
    super.filePath,
  });

  factory ResourceModel.fromMap(Map<String, Object?> map) {
    return ResourceModel(
      id: (map['id'] as String?) ?? '',
      title: (map['title'] as String?) ?? 'Unknown Title',
      description: (map['description'] as String?) ?? '',
      courseCode: (map['courseCode'] as String?) ?? 'N/A',
      rating: (map['rating'] as num?)?.toDouble() ?? 0.0,
      reviewCount: (map['reviewCount'] as int?) ?? 0,
      uses: (map['uses'] as int?) ?? 0,
      fileType: (map['fileType'] as String?) ?? 'N/A',
      uploader: (map['uploader'] as String?) ?? 'Unknown',
      isApproved: (map['isApproved'] as int?) == 1,
      isBookmarked: (map['isBookmarked'] as int?) == 1,
      isDownloaded: (map['isDownloaded'] as int?) == 1,
      filePath: map['file_path'] as String?,
    );
  }

  factory ResourceModel.empty(String id) {
    return ResourceModel(
      id: id,
      title: 'Unknown Resource',
      description: 'Details are not available for this resource.',
      courseCode: 'N/A',
      rating: 0.0,
      reviewCount: 0,
      uses: 0,
      fileType: 'N/A',
      uploader: 'Unknown',
      isApproved: false,
      isBookmarked: false,
      isDownloaded: false,
    );
  }

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'courseCode': courseCode,
      'rating': rating,
      'reviewCount': reviewCount,
      'uses': uses,
      'fileType': fileType,
      'uploader': uploader,
      'isApproved': isApproved ? 1 : 0,
      'isBookmarked': isBookmarked ? 1 : 0,
      'isDownloaded': isDownloaded ? 1 : 0,
      'file_path': filePath,
    };
  }

  ResourceModel copyWith({
    String? id,
    String? title,
    String? description,
    String? courseCode,
    double? rating,
    int? reviewCount,
    int? uses,
    String? fileType,
    String? uploader,
    bool? isApproved,
    bool? isBookmarked,
    bool? isDownloaded,
    String? filePath,
  }) {
    return ResourceModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      courseCode: courseCode ?? this.courseCode,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      uses: uses ?? this.uses,
      fileType: fileType ?? this.fileType,
      uploader: uploader ?? this.uploader,
      isApproved: isApproved ?? this.isApproved,
      isBookmarked: isBookmarked ?? this.isBookmarked,
      isDownloaded: isDownloaded ?? this.isDownloaded,
      filePath: filePath ?? this.filePath,
    );
  }
}
