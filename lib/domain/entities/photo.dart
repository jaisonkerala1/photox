import 'package:equatable/equatable.dart';

enum EditType {
  none,
  enhance,
  restore,
  selfieEdit,
  faceSwap,
  aging,
  babyGenerator,
  animate,
  styleTransfer,
  upscale,
  filter,
}

enum PhotoStatus {
  pending,
  processing,
  completed,
  failed,
}

class Photo extends Equatable {
  final String id;
  final String userId;
  final String originalUrl;
  final String? editedUrl;
  final String? thumbnailUrl;
  final EditType editType;
  final PhotoStatus status;
  final Map<String, dynamic>? parameters;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const Photo({
    required this.id,
    required this.userId,
    required this.originalUrl,
    this.editedUrl,
    this.thumbnailUrl,
    required this.editType,
    required this.status,
    this.parameters,
    required this.createdAt,
    this.updatedAt,
  });

  bool get isProcessing => status == PhotoStatus.processing;
  bool get isCompleted => status == PhotoStatus.completed;
  bool get hasFailed => status == PhotoStatus.failed;
  bool get hasResult => editedUrl != null && editedUrl!.isNotEmpty;

  String get displayUrl => editedUrl ?? originalUrl;

  @override
  List<Object?> get props => [
    id,
    userId,
    originalUrl,
    editedUrl,
    thumbnailUrl,
    editType,
    status,
    parameters,
    createdAt,
    updatedAt,
  ];
}





