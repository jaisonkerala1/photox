import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

import '../../config/constants.dart';

class EnhanceService {
  static const String _baseUrl = AppConstants.baseUrl;

  /// Enhance image using Gemini API
  /// Returns the path to the enhanced image saved locally
  static Future<EnhanceResult> enhanceImage({
    required String imagePath,
    required String enhanceType,
  }) async {
    try {
      // Read the image file and convert to base64
      final file = File(imagePath);
      if (!await file.exists()) {
        throw Exception('Image file not found');
      }

      final bytes = await file.readAsBytes();
      final base64Image = base64Encode(bytes);

      // Determine mime type
      final extension = imagePath.split('.').last.toLowerCase();
      String mimeType = 'image/jpeg';
      if (extension == 'png') {
        mimeType = 'image/png';
      } else if (extension == 'webp') {
        mimeType = 'image/webp';
      }

      // Call the enhance API
      final response = await http.post(
        Uri.parse('$_baseUrl${ApiEndpoints.enhancePublic}'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'imageBase64': base64Image,
          'mimeType': mimeType,
          'enhanceType': enhanceType,
        }),
      ).timeout(const Duration(seconds: 120));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        if (data['success'] == true && data['enhancedImageBase64'] != null) {
          // Save the enhanced image locally
          final enhancedBytes = base64Decode(data['enhancedImageBase64']);
          final tempDir = await getTemporaryDirectory();
          final timestamp = DateTime.now().millisecondsSinceEpoch;
          final enhancedPath = '${tempDir.path}/enhanced_$timestamp.png';
          
          final enhancedFile = File(enhancedPath);
          await enhancedFile.writeAsBytes(enhancedBytes);

          return EnhanceResult(
            success: true,
            enhancedImagePath: enhancedPath,
            processingTime: data['processingTime'] ?? 0,
          );
        } else {
          throw Exception(data['message'] ?? 'Enhancement failed');
        }
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Server error: ${response.statusCode}');
      }
    } catch (e) {
      return EnhanceResult(
        success: false,
        error: e.toString(),
      );
    }
  }
}

class EnhanceResult {
  final bool success;
  final String? enhancedImagePath;
  final int processingTime;
  final String? error;

  EnhanceResult({
    required this.success,
    this.enhancedImagePath,
    this.processingTime = 0,
    this.error,
  });
}

