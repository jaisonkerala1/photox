import 'dart:io';

import '../../entities/edit_result.dart';
import '../../repositories/ai_processing_repository.dart';

class RestorePhotoUseCase {
  final AIProcessingRepository _repository;

  RestorePhotoUseCase(this._repository);

  Future<EditResult> call(
    File image, {
    bool colorize = false,
    bool removeDamage = true,
  }) {
    return _repository.restorePhoto(
      image,
      colorize: colorize,
      removeDamage: removeDamage,
    );
  }
}





