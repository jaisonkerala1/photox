import 'dart:io';

import 'package:equatable/equatable.dart';

import '../../../domain/entities/photo.dart';

abstract class PhotoEditorEvent extends Equatable {
  const PhotoEditorEvent();

  @override
  List<Object?> get props => [];
}

class PhotoEditorImageSelected extends PhotoEditorEvent {
  final File image;

  const PhotoEditorImageSelected(this.image);

  @override
  List<Object?> get props => [image];
}

class PhotoEditorEnhanceRequested extends PhotoEditorEvent {
  final File image;
  final int? intensity;

  const PhotoEditorEnhanceRequested({
    required this.image,
    this.intensity,
  });

  @override
  List<Object?> get props => [image, intensity];
}

class PhotoEditorRestoreRequested extends PhotoEditorEvent {
  final File image;
  final bool colorize;
  final bool removeDamage;

  const PhotoEditorRestoreRequested({
    required this.image,
    this.colorize = false,
    this.removeDamage = true,
  });

  @override
  List<Object?> get props => [image, colorize, removeDamage];
}

class PhotoEditorFaceSwapRequested extends PhotoEditorEvent {
  final File sourceImage;
  final File targetImage;

  const PhotoEditorFaceSwapRequested({
    required this.sourceImage,
    required this.targetImage,
  });

  @override
  List<Object?> get props => [sourceImage, targetImage];
}

class PhotoEditorAgingRequested extends PhotoEditorEvent {
  final File image;
  final int targetAge;

  const PhotoEditorAgingRequested({
    required this.image,
    required this.targetAge,
  });

  @override
  List<Object?> get props => [image, targetAge];
}

class PhotoEditorStyleTransferRequested extends PhotoEditorEvent {
  final File image;
  final String style;

  const PhotoEditorStyleTransferRequested({
    required this.image,
    required this.style,
  });

  @override
  List<Object?> get props => [image, style];
}

class PhotoEditorFilterRequested extends PhotoEditorEvent {
  final File image;
  final String filterName;

  const PhotoEditorFilterRequested({
    required this.image,
    required this.filterName,
  });

  @override
  List<Object?> get props => [image, filterName];
}

class PhotoEditorReset extends PhotoEditorEvent {
  const PhotoEditorReset();
}

class PhotoEditorSaveRequested extends PhotoEditorEvent {
  final String resultUrl;

  const PhotoEditorSaveRequested(this.resultUrl);

  @override
  List<Object?> get props => [resultUrl];
}





