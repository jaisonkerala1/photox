import 'dart:io';

import 'package:flutter/material.dart';

import '../../config/theme/app_colors.dart';

// Stub implementation - image picker functionality will be added later
class ImagePickerUtil {
  static Future<File?> pickFromGallery({
    int maxWidth = 2048,
    int maxHeight = 2048,
    int imageQuality = 85,
  }) async {
    debugPrint('Image picker not implemented yet');
    return null;
  }

  static Future<File?> pickFromCamera({
    int maxWidth = 2048,
    int maxHeight = 2048,
    int imageQuality = 85,
  }) async {
    debugPrint('Image picker not implemented yet');
    return null;
  }

  static Future<List<File>?> pickMultipleFromGallery({
    int maxWidth = 2048,
    int maxHeight = 2048,
    int imageQuality = 85,
    int? limit,
  }) async {
    debugPrint('Image picker not implemented yet');
    return null;
  }

  static Future<File?> cropImage(File imageFile) async {
    return imageFile;
  }

  static Future<void> showImageSourceDialog(
    BuildContext context, {
    required Function(File) onImageSelected,
    bool allowCrop = true,
  }) async {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.textTertiary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Select Image',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Image picker not implemented yet',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
