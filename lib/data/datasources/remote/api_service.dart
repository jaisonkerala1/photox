import 'dart:io';

import '../../../config/constants.dart';
import '../../../core/network/api_client.dart';

class ApiService {
  final ApiClient _client;

  ApiService(this._client);

  // Auth
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) {
    return _client.post(
      ApiEndpoints.login,
      data: {'email': email, 'password': password},
    );
  }

  Future<Map<String, dynamic>> register({
    required String email,
    required String password,
    required String name,
  }) {
    return _client.post(
      ApiEndpoints.register,
      data: {'email': email, 'password': password, 'name': name},
    );
  }

  Future<Map<String, dynamic>> refreshToken(String refreshToken) {
    return _client.post(
      ApiEndpoints.refreshToken,
      data: {'refreshToken': refreshToken},
    );
  }

  Future<Map<String, dynamic>> getProfile() {
    return _client.get(ApiEndpoints.profile);
  }

  Future<Map<String, dynamic>> updateProfile({
    String? name,
    String? profilePicture,
  }) {
    return _client.put(
      ApiEndpoints.updateProfile,
      data: {
        if (name != null) 'name': name,
        if (profilePicture != null) 'profilePicture': profilePicture,
      },
    );
  }

  // Photos
  Future<Map<String, dynamic>> getPhotos({
    int page = 1,
    int limit = 20,
    String? editType,
  }) {
    return _client.get(
      ApiEndpoints.photos,
      queryParameters: {
        'page': page,
        'limit': limit,
        if (editType != null) 'editType': editType,
      },
    );
  }

  Future<Map<String, dynamic>> getPhoto(String id) {
    return _client.get(ApiEndpoints.getPhoto(id));
  }

  Future<Map<String, dynamic>> uploadPhoto(File file) {
    return _client.uploadFile(
      ApiEndpoints.uploadPhoto,
      file: file,
      fieldName: 'photo',
    );
  }

  Future<Map<String, dynamic>> deletePhoto(String id) {
    return _client.delete(ApiEndpoints.deletePhoto(id));
  }

  // AI Processing
  Future<Map<String, dynamic>> enhancePhoto(
    File image, {
    int? intensity,
  }) {
    return _client.uploadFile(
      ApiEndpoints.enhance,
      file: image,
      fieldName: 'image',
      additionalData: {
        if (intensity != null) 'intensity': intensity,
      },
    );
  }

  Future<Map<String, dynamic>> restorePhoto(
    File image, {
    bool colorize = false,
    bool removeDamage = true,
  }) {
    return _client.uploadFile(
      ApiEndpoints.restore,
      file: image,
      fieldName: 'image',
      additionalData: {
        'colorize': colorize,
        'removeDamage': removeDamage,
      },
    );
  }

  Future<Map<String, dynamic>> editSelfie(
    File image, {
    int? smoothness,
    int? brighten,
    bool? removeAcne,
  }) {
    return _client.uploadFile(
      ApiEndpoints.selfieEdit,
      file: image,
      fieldName: 'image',
      additionalData: {
        if (smoothness != null) 'smoothness': smoothness,
        if (brighten != null) 'brighten': brighten,
        if (removeAcne != null) 'removeAcne': removeAcne,
      },
    );
  }

  Future<Map<String, dynamic>> faceSwap(File sourceImage, File targetImage) {
    return _client.uploadMultipleFiles(
      ApiEndpoints.faceSwap,
      files: [sourceImage, targetImage],
      fieldName: 'images',
    );
  }

  Future<Map<String, dynamic>> applyAging(File image, int targetAge) {
    return _client.uploadFile(
      ApiEndpoints.aging,
      file: image,
      fieldName: 'image',
      additionalData: {'targetAge': targetAge},
    );
  }

  Future<Map<String, dynamic>> generateBaby(File parent1, File parent2) {
    return _client.uploadMultipleFiles(
      ApiEndpoints.babyGenerator,
      files: [parent1, parent2],
      fieldName: 'parents',
    );
  }

  Future<Map<String, dynamic>> animatePhoto(File image, String animationType) {
    return _client.uploadFile(
      ApiEndpoints.animate,
      file: image,
      fieldName: 'image',
      additionalData: {'animationType': animationType},
    );
  }

  Future<Map<String, dynamic>> applyStyleTransfer(File image, String style) {
    return _client.uploadFile(
      ApiEndpoints.styleTransfer,
      file: image,
      fieldName: 'image',
      additionalData: {'style': style},
    );
  }

  Future<Map<String, dynamic>> upscaleImage(File image, {int factor = 2}) {
    return _client.uploadFile(
      ApiEndpoints.upscale,
      file: image,
      fieldName: 'image',
      additionalData: {'factor': factor},
    );
  }

  Future<Map<String, dynamic>> applyFilter(File image, String filterName) {
    return _client.uploadFile(
      ApiEndpoints.applyFilter,
      file: image,
      fieldName: 'image',
      additionalData: {'filter': filterName},
    );
  }

  // Subscription
  Future<Map<String, dynamic>> getPlans() {
    return _client.get(ApiEndpoints.plans);
  }

  Future<Map<String, dynamic>> getSubscriptionStatus() {
    return _client.get(ApiEndpoints.subscriptionStatus);
  }

  Future<Map<String, dynamic>> purchaseSubscription({
    required String planId,
    required String paymentMethod,
    bool isYearly = false,
  }) {
    return _client.post(
      ApiEndpoints.purchase,
      data: {
        'planId': planId,
        'paymentMethod': paymentMethod,
        'isYearly': isYearly,
      },
    );
  }

  Future<Map<String, dynamic>> cancelSubscription() {
    return _client.post(ApiEndpoints.cancelSubscription);
  }

  // History
  Future<Map<String, dynamic>> getHistory({
    int page = 1,
    int limit = 20,
  }) {
    return _client.get(
      ApiEndpoints.history,
      queryParameters: {'page': page, 'limit': limit},
    );
  }

  Future<Map<String, dynamic>> deleteHistory(String id) {
    return _client.delete(ApiEndpoints.deleteHistory(id));
  }
}


