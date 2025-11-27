import 'package:equatable/equatable.dart';

import 'photo.dart';

class EditResult extends Equatable {
  final String id;
  final String originalImagePath;
  final String resultImagePath;
  final EditType editType;
  final Map<String, dynamic>? parameters;
  final int processingTime;
  final int creditsCost;
  final DateTime createdAt;

  const EditResult({
    required this.id,
    required this.originalImagePath,
    required this.resultImagePath,
    required this.editType,
    this.parameters,
    required this.processingTime,
    required this.creditsCost,
    required this.createdAt,
  });

  String get formattedProcessingTime {
    if (processingTime < 1000) {
      return '${processingTime}ms';
    } else {
      final seconds = (processingTime / 1000).toStringAsFixed(1);
      return '${seconds}s';
    }
  }

  String get editTypeName {
    switch (editType) {
      case EditType.enhance:
        return 'Enhanced';
      case EditType.restore:
        return 'Restored';
      case EditType.selfieEdit:
        return 'Beautified';
      case EditType.faceSwap:
        return 'Face Swapped';
      case EditType.aging:
        return 'Aged';
      case EditType.babyGenerator:
        return 'Baby Generated';
      case EditType.animate:
        return 'Animated';
      case EditType.styleTransfer:
        return 'Styled';
      case EditType.upscale:
        return 'Upscaled';
      case EditType.filter:
        return 'Filtered';
      case EditType.none:
        return 'Edited';
    }
  }

  @override
  List<Object?> get props => [
    id,
    originalImagePath,
    resultImagePath,
    editType,
    parameters,
    processingTime,
    creditsCost,
    createdAt,
  ];
}

class AIProcessingParams extends Equatable {
  final String? style;
  final int? intensity;
  final int? age;
  final String? filterName;
  final bool? colorize;
  final bool? removeDamage;
  final int? upscaleFactor;
  
  const AIProcessingParams({
    this.style,
    this.intensity,
    this.age,
    this.filterName,
    this.colorize,
    this.removeDamage,
    this.upscaleFactor,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (style != null) map['style'] = style;
    if (intensity != null) map['intensity'] = intensity;
    if (age != null) map['age'] = age;
    if (filterName != null) map['filterName'] = filterName;
    if (colorize != null) map['colorize'] = colorize;
    if (removeDamage != null) map['removeDamage'] = removeDamage;
    if (upscaleFactor != null) map['upscaleFactor'] = upscaleFactor;
    return map;
  }

  @override
  List<Object?> get props => [style, intensity, age, filterName, colorize, removeDamage, upscaleFactor];
}





