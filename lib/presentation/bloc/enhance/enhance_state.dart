import 'package:equatable/equatable.dart';
import 'enhance_event.dart';

enum EnhanceStatus {
  initial,
  loading,
  processing,
  success,
  error,
  saved,
}

class EnhanceState extends Equatable {
  final EnhanceStatus status;
  final String? originalImagePath;
  final String? enhancedImagePath;
  final EnhanceType enhanceType;
  final double intensity;
  final double progress;
  final double comparisonPosition;
  final String? errorMessage;
  final bool isEnhanced;

  const EnhanceState({
    this.status = EnhanceStatus.initial,
    this.originalImagePath,
    this.enhancedImagePath,
    this.enhanceType = EnhanceType.auto,
    this.intensity = 0.8,
    this.progress = 0.0,
    this.comparisonPosition = 0.5,
    this.errorMessage,
    this.isEnhanced = false,
  });

  bool get isProcessing => status == EnhanceStatus.processing;
  bool get isLoading => status == EnhanceStatus.loading;
  bool get hasError => status == EnhanceStatus.error;
  bool get isSaved => status == EnhanceStatus.saved;

  EnhanceState copyWith({
    EnhanceStatus? status,
    String? originalImagePath,
    String? enhancedImagePath,
    EnhanceType? enhanceType,
    double? intensity,
    double? progress,
    double? comparisonPosition,
    String? errorMessage,
    bool? isEnhanced,
  }) {
    return EnhanceState(
      status: status ?? this.status,
      originalImagePath: originalImagePath ?? this.originalImagePath,
      enhancedImagePath: enhancedImagePath ?? this.enhancedImagePath,
      enhanceType: enhanceType ?? this.enhanceType,
      intensity: intensity ?? this.intensity,
      progress: progress ?? this.progress,
      comparisonPosition: comparisonPosition ?? this.comparisonPosition,
      errorMessage: errorMessage ?? this.errorMessage,
      isEnhanced: isEnhanced ?? this.isEnhanced,
    );
  }

  @override
  List<Object?> get props => [
        status,
        originalImagePath,
        enhancedImagePath,
        enhanceType,
        intensity,
        progress,
        comparisonPosition,
        errorMessage,
        isEnhanced,
      ];
}

