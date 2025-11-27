import 'dart:io';

import '../../entities/edit_result.dart';
import '../../repositories/ai_processing_repository.dart';

class ApplyFilterUseCase {
  final AIProcessingRepository _repository;

  ApplyFilterUseCase(this._repository);

  Future<EditResult> call(File image, String filterName) {
    return _repository.applyFilter(image, filterName);
  }
}





