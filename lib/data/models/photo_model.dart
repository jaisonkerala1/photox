import '../../domain/entities/photo.dart';

class PhotoModel extends Photo {
  const PhotoModel({
    required super.id,
    required super.userId,
    required super.originalUrl,
    super.editedUrl,
    super.thumbnailUrl,
    required super.editType,
    required super.status,
    super.parameters,
    required super.createdAt,
    super.updatedAt,
  });

  factory PhotoModel.fromJson(Map<String, dynamic> json) {
    return PhotoModel(
      id: json['id'] ?? json['_id'] ?? '',
      userId: json['userId'] ?? json['user_id'] ?? '',
      originalUrl: json['originalUrl'] ?? json['original_url'] ?? '',
      editedUrl: json['editedUrl'] ?? json['edited_url'],
      thumbnailUrl: json['thumbnailUrl'] ?? json['thumbnail_url'],
      editType: EditType.values.firstWhere(
        (e) => e.name == (json['editType'] ?? json['edit_type'] ?? 'none'),
        orElse: () => EditType.none,
      ),
      status: PhotoStatus.values.firstWhere(
        (e) => e.name == (json['status'] ?? 'pending'),
        orElse: () => PhotoStatus.pending,
      ),
      parameters: json['parameters'] != null
          ? Map<String, dynamic>.from(json['parameters'])
          : null,
      createdAt: DateTime.parse(
        json['createdAt'] ?? json['created_at'] ?? DateTime.now().toIso8601String(),
      ),
      updatedAt: json['updatedAt'] != null || json['updated_at'] != null
          ? DateTime.parse(json['updatedAt'] ?? json['updated_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'originalUrl': originalUrl,
      'editedUrl': editedUrl,
      'thumbnailUrl': thumbnailUrl,
      'editType': editType.name,
      'status': status.name,
      'parameters': parameters,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  PhotoModel copyWith({
    String? id,
    String? userId,
    String? originalUrl,
    String? editedUrl,
    String? thumbnailUrl,
    EditType? editType,
    PhotoStatus? status,
    Map<String, dynamic>? parameters,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PhotoModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      originalUrl: originalUrl ?? this.originalUrl,
      editedUrl: editedUrl ?? this.editedUrl,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      editType: editType ?? this.editType,
      status: status ?? this.status,
      parameters: parameters ?? this.parameters,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class PhotoListResponse {
  final List<PhotoModel> photos;
  final int total;
  final int page;
  final int limit;
  final bool hasMore;

  PhotoListResponse({
    required this.photos,
    required this.total,
    required this.page,
    required this.limit,
    required this.hasMore,
  });

  factory PhotoListResponse.fromJson(Map<String, dynamic> json) {
    return PhotoListResponse(
      photos: (json['photos'] ?? json['data'] ?? [])
          .map<PhotoModel>((e) => PhotoModel.fromJson(e))
          .toList(),
      total: json['total'] ?? 0,
      page: json['page'] ?? 1,
      limit: json['limit'] ?? 20,
      hasMore: json['hasMore'] ?? json['has_more'] ?? false,
    );
  }
}


