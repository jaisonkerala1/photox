import 'dart:io';

import '../../entities/edit_result.dart';
import '../../repositories/ai_processing_repository.dart';

class EnhancePhotoUseCase {
  final AIProcessingRepository _repository;

  EnhancePhotoUseCase(this._repository);

  Future<EditResult> call(File image, {int? intensity}) {
    return _repository.enhancePhoto(image, intensity: intensity);
  }
}


