import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../config/theme/app_colors.dart';

class ImagePickerUtil {
  static final ImagePicker _picker = ImagePicker();

  static Future<File?> pickFromGallery({
    int maxWidth = 2048,
    int maxHeight = 2048,
    int imageQuality = 85,
  }) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: maxWidth.toDouble(),
        maxHeight: maxHeight.toDouble(),
        imageQuality: imageQuality,
      );
      
      if (image != null) {
        return File(image.path);
      }
      return null;
    } catch (e) {
      debugPrint('Error picking image from gallery: $e');
      return null;
    }
  }

  static Future<File?> pickFromCamera({
    int maxWidth = 2048,
    int maxHeight = 2048,
    int imageQuality = 85,
  }) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: maxWidth.toDouble(),
        maxHeight: maxHeight.toDouble(),
        imageQuality: imageQuality,
      );
      
      if (image != null) {
        return File(image.path);
      }
      return null;
    } catch (e) {
      debugPrint('Error picking image from camera: $e');
      return null;
    }
  }

  static Future<List<File>?> pickMultipleFromGallery({
    int maxWidth = 2048,
    int maxHeight = 2048,
    int imageQuality = 85,
    int? limit,
  }) async {
    try {
      final List<XFile>? images = await _picker.pickMultiImage(
        maxWidth: maxWidth.toDouble(),
        maxHeight: maxHeight.toDouble(),
        imageQuality: imageQuality,
      );
      
      if (images != null && images.isNotEmpty) {
        var result = images.map((xFile) => File(xFile.path)).toList();
        if (limit != null && result.length > limit) {
          result = result.sublist(0, limit);
        }
        return result;
      }
      return null;
    } catch (e) {
      debugPrint('Error picking multiple images: $e');
      return null;
    }
  }

  static Future<File?> cropImage(File imageFile) async {
    // For now, return the original image
    // Can be enhanced with image_cropper package later
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
              // Drag handle
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.cardBorder,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 24),
              
              // Title
              Text(
                'Select Image',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 24),
              
              // Options
              Row(
                children: [
                  // Gallery Option
                  Expanded(
                    child: _SourceOption(
                      icon: Icons.photo_library_rounded,
                      label: 'Gallery',
                      onTap: () async {
                        Navigator.pop(context);
                        final file = await pickFromGallery();
                        if (file != null) {
                          final processedFile = allowCrop 
                              ? await cropImage(file) 
                              : file;
                          if (processedFile != null) {
                            onImageSelected(processedFile);
                          }
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Camera Option
                  Expanded(
                    child: _SourceOption(
                      icon: Icons.camera_alt_rounded,
                      label: 'Camera',
                      onTap: () async {
                        Navigator.pop(context);
                        final file = await pickFromCamera();
                        if (file != null) {
                          final processedFile = allowCrop 
                              ? await cropImage(file) 
                              : file;
                          if (processedFile != null) {
                            onImageSelected(processedFile);
                          }
                        }
                      },
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Cancel button
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Cancel',
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SourceOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _SourceOption({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 24),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.cardBorder),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Color(0xFF7C3AED).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 32,
                color: Color(0xFF7C3AED),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
