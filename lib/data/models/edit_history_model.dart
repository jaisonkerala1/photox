import '../../domain/entities/photo.dart';

class EditHistoryModel {
  final String id;
  final String userId;
  final String photoId;
  final EditType editType;
  final Map<String, dynamic>? parameters;
  final String originalUrl;
  final String resultUrl;
  final int processingTime;
  final int cost;
  final DateTime createdAt;

  const EditHistoryModel({
    required this.id,
    required this.userId,
    required this.photoId,
    required this.editType,
    this.parameters,
    required this.originalUrl,
    required this.resultUrl,
    required this.processingTime,
    required this.cost,
    required this.createdAt,
  });

  factory EditHistoryModel.fromJson(Map<String, dynamic> json) {
    return EditHistoryModel(
      id: json['id'] ?? json['_id'] ?? '',
      userId: json['userId'] ?? json['user_id'] ?? '',
      photoId: json['photoId'] ?? json['photo_id'] ?? '',
      editType: EditType.values.firstWhere(
        (e) => e.name == (json['editType'] ?? json['edit_type'] ?? 'none'),
        orElse: () => EditType.none,
      ),
      parameters: json['parameters'] != null
          ? Map<String, dynamic>.from(json['parameters'])
          : null,
      originalUrl: json['originalUrl'] ?? json['original_url'] ?? '',
      resultUrl: json['resultUrl'] ?? json['result_url'] ?? '',
      processingTime: json['processingTime'] ?? json['processing_time'] ?? 0,
      cost: json['cost'] ?? 1,
      createdAt: DateTime.parse(
        json['createdAt'] ?? json['created_at'] ?? DateTime.now().toIso8601String(),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'photoId': photoId,
      'editType': editType.name,
      'parameters': parameters,
      'originalUrl': originalUrl,
      'resultUrl': resultUrl,
      'processingTime': processingTime,
      'cost': cost,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  String get editTypeName {
    switch (editType) {
      case EditType.enhance:
        return 'Photo Enhancement';
      case EditType.restore:
        return 'Photo Restoration';
      case EditType.selfieEdit:
        return 'Selfie Edit';
      case EditType.faceSwap:
        return 'Face Swap';
      case EditType.aging:
        return 'AI Aging';
      case EditType.babyGenerator:
        return 'Baby Generator';
      case EditType.animate:
        return 'Photo Animation';
      case EditType.styleTransfer:
        return 'Style Transfer';
      case EditType.upscale:
        return 'HD Upscale';
      case EditType.filter:
        return 'Filter Applied';
      case EditType.none:
        return 'Unknown';
    }
  }

  String get formattedProcessingTime {
    if (processingTime < 1000) {
      return '${processingTime}ms';
    } else {
      return '${(processingTime / 1000).toStringAsFixed(1)}s';
    }
  }
}

class EditHistoryListResponse {
  final List<EditHistoryModel> history;
  final int total;
  final int page;
  final int limit;
  final bool hasMore;

  EditHistoryListResponse({
    required this.history,
    required this.total,
    required this.page,
    required this.limit,
    required this.hasMore,
  });

  factory EditHistoryListResponse.fromJson(Map<String, dynamic> json) {
    return EditHistoryListResponse(
      history: (json['history'] ?? json['data'] ?? [])
          .map<EditHistoryModel>((e) => EditHistoryModel.fromJson(e))
          .toList(),
      total: json['total'] ?? 0,
      page: json['page'] ?? 1,
      limit: json['limit'] ?? 20,
      hasMore: json['hasMore'] ?? json['has_more'] ?? false,
    );
  }
}


