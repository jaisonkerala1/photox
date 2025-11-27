import 'dart:io';

import '../../entities/edit_result.dart';
import '../../repositories/ai_processing_repository.dart';

class FaceSwapUseCase {
  final AIProcessingRepository _repository;

  FaceSwapUseCase(this._repository);

  Future<EditResult> call(File sourceImage, File targetImage) {
    return _repository.faceSwap(sourceImage, targetImage);
  }
}





