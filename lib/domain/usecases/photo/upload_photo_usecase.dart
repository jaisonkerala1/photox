import 'dart:io';

import '../../entities/photo.dart';
import '../../repositories/photo_repository.dart';

class UploadPhotoUseCase {
  final PhotoRepository _repository;

  UploadPhotoUseCase(this._repository);

  Future<Photo> call(File file) {
    return _repository.uploadPhoto(file);
  }
}


