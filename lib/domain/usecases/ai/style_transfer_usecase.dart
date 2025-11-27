import 'dart:io';

import '../../entities/edit_result.dart';
import '../../repositories/ai_processing_repository.dart';

class StyleTransferUseCase {
  final AIProcessingRepository _repository;

  StyleTransferUseCase(this._repository);

  Future<EditResult> call(File image, String style) {
    return _repository.applyStyleTransfer(image, style);
  }
}





