import 'dart:io';

import '../../entities/edit_result.dart';
import '../../repositories/ai_processing_repository.dart';

class AgingEffectUseCase {
  final AIProcessingRepository _repository;

  AgingEffectUseCase(this._repository);

  Future<EditResult> call(File image, int targetAge) {
    return _repository.applyAging(image, targetAge);
  }
}





