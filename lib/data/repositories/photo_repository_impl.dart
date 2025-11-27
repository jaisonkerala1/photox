import 'dart:io';

import 'package:dio/dio.dart';

import '../../domain/entities/photo.dart';
import '../../domain/repositories/photo_repository.dart';
import '../datasources/remote/api_service.dart';
import '../models/photo_model.dart';

class PhotoRepositoryImpl implements PhotoRepository {
  final ApiService apiService;

  PhotoRepositoryImpl({required this.apiService});

  @override
  Future<List<Photo>> getPhotos({
    int page = 1,
    int limit = 20,
    EditType? editType,
  }) async {
    final response = await apiService.getPhotos(
      page: page,
      limit: limit,
      editType: editType?.name,
    );
    final photoList = PhotoListResponse.fromJson(response);
    return photoList.photos;
  }

  @override
  Future<Photo> getPhoto(String id) async {
    final response = await apiService.getPhoto(id);
    return PhotoModel.fromJson(response['photo'] ?? response);
  }

  @override
  Future<Photo> uploadPhoto(File file) async {
    final response = await apiService.uploadPhoto(file);
    return PhotoModel.fromJson(response['photo'] ?? response);
  }

  @override
  Future<void> deletePhoto(String id) async {
    await apiService.deletePhoto(id);
  }

  @override
  Future<String> downloadPhoto(String url, String fileName) async {
    // Stub implementation - will use proper path provider later
    final filePath = '/tmp/$fileName';
    
    final dio = Dio();
    await dio.download(url, filePath);
    
    return filePath;
  }
}





