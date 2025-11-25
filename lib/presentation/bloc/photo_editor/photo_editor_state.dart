import 'dart:io';

import 'package:equatable/equatable.dart';

import '../../../domain/entities/edit_result.dart';
import '../../../domain/entities/photo.dart';

enum PhotoEditorStatus {
  initial,
  imageSelected,
  processing,
  completed,
  saved,
  error,
}

class PhotoEditorState extends Equatable {
  final PhotoEditorStatus status;
  final File? selectedImage;
  final EditResult? result;
  final EditType? currentEditType;
  final double? progress;
  final String? errorMessage;
  final String? processingMessage;

  const PhotoEditorState({
    this.status = PhotoEditorStatus.initial,
    this.selectedImage,
    this.result,
    this.currentEditType,
    this.progress,
    this.errorMessage,
    this.processingMessage,
  });

  const PhotoEditorState.initial() : this();

  PhotoEditorState copyWith({
    PhotoEditorStatus? status,
    File? selectedImage,
    EditResult? result,
    EditType? currentEditType,
    double? progress,
    String? errorMessage,
    String? processingMessage,
  }) {
    return PhotoEditorState(
      status: status ?? this.status,
      selectedImage: selectedImage ?? this.selectedImage,
      result: result ?? this.result,
      currentEditType: currentEditType ?? this.currentEditType,
      progress: progress ?? this.progress,
      errorMessage: errorMessage ?? this.errorMessage,
      processingMessage: processingMessage ?? this.processingMessage,
    );
  }

  bool get isProcessing => status == PhotoEditorStatus.processing;
  bool get isCompleted => status == PhotoEditorStatus.completed;
  bool get hasError => status == PhotoEditorStatus.error;
  bool get hasResult => result != null;

  @override
  List<Object?> get props => [
    status,
    selectedImage,
    result,
    currentEditType,
    progress,
    errorMessage,
    processingMessage,
  ];
}


