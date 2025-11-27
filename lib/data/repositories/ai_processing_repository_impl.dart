import 'dart:io';

import '../../domain/entities/edit_result.dart';
import '../../domain/entities/photo.dart';
import '../../domain/repositories/ai_processing_repository.dart';
import '../datasources/remote/api_service.dart';

class AIProcessingRepositoryImpl implements AIProcessingRepository {
  final ApiService apiService;

  AIProcessingRepositoryImpl({required this.apiService});

  EditResult _parseEditResult(Map<String, dynamic> response, EditType editType) {
    return EditResult(
      id: response['id'] ?? response['_id'] ?? '',
      originalImagePath: response['originalUrl'] ?? response['original_url'] ?? '',
      resultImagePath: response['resultUrl'] ?? response['result_url'] ?? '',
      editType: editType,
      parameters: response['parameters'],
      processingTime: response['processingTime'] ?? response['processing_time'] ?? 0,
      creditsCost: response['creditsCost'] ?? response['credits_cost'] ?? 1,
      createdAt: DateTime.parse(
        response['createdAt'] ?? response['created_at'] ?? DateTime.now().toIso8601String(),
      ),
    );
  }

  @override
  Future<EditResult> enhancePhoto(File image, {int? intensity}) async {
    final response = await apiService.enhancePhoto(image, intensity: intensity);
    return _parseEditResult(response, EditType.enhance);
  }

  @override
  Future<EditResult> restorePhoto(
    File image, {
    bool colorize = false,
    bool removeDamage = true,
  }) async {
    final response = await apiService.restorePhoto(
      image,
      colorize: colorize,
      removeDamage: removeDamage,
    );
    return _parseEditResult(response, EditType.restore);
  }

  @override
  Future<EditResult> editSelfie(
    File image, {
    int? smoothness,
    int? brighten,
    bool? removeAcne,
  }) async {
    final response = await apiService.editSelfie(
      image,
      smoothness: smoothness,
      brighten: brighten,
      removeAcne: removeAcne,
    );
    return _parseEditResult(response, EditType.selfieEdit);
  }

  @override
  Future<EditResult> faceSwap(File sourceImage, File targetImage) async {
    final response = await apiService.faceSwap(sourceImage, targetImage);
    return _parseEditResult(response, EditType.faceSwap);
  }

  @override
  Future<EditResult> applyAging(File image, int targetAge) async {
    final response = await apiService.applyAging(image, targetAge);
    return _parseEditResult(response, EditType.aging);
  }

  @override
  Future<EditResult> generateBaby(File parentImage1, File parentImage2) async {
    final response = await apiService.generateBaby(parentImage1, parentImage2);
    return _parseEditResult(response, EditType.babyGenerator);
  }

  @override
  Future<EditResult> animatePhoto(File image, String animationType) async {
    final response = await apiService.animatePhoto(image, animationType);
    return _parseEditResult(response, EditType.animate);
  }

  @override
  Future<EditResult> applyStyleTransfer(File image, String style) async {
    final response = await apiService.applyStyleTransfer(image, style);
    return _parseEditResult(response, EditType.styleTransfer);
  }

  @override
  Future<EditResult> upscaleImage(File image, {int factor = 2}) async {
    final response = await apiService.upscaleImage(image, factor: factor);
    return _parseEditResult(response, EditType.upscale);
  }

  @override
  Future<EditResult> applyFilter(File image, String filterName) async {
    final response = await apiService.applyFilter(image, filterName);
    return _parseEditResult(response, EditType.filter);
  }

  @override
  Future<PhotoStatus> checkProcessingStatus(String processId) async {
    // TODO: Implement status checking endpoint
    return PhotoStatus.completed;
  }
}





