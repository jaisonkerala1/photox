import 'dart:io';

import '../entities/photo.dart';

abstract class PhotoRepository {
  Future<List<Photo>> getPhotos({
    int page = 1,
    int limit = 20,
    EditType? editType,
  });

  Future<Photo> getPhoto(String id);

  Future<Photo> uploadPhoto(File file);

  Future<void> deletePhoto(String id);

  Future<String> downloadPhoto(String url, String fileName);
}





