import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';

import '../../config/theme/app_colors.dart';
import '../../domain/entities/photo.dart';

class PhotoCard extends StatelessWidget {
  final Photo photo;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  const PhotoCard({
    super.key,
    required this.photo,
    this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Image
              CachedNetworkImage(
                imageUrl: photo.displayUrl,
                fit: BoxFit.cover,
                placeholder: (context, url) => Shimmer.fromColors(
                  baseColor: AppColors.shimmerBase,
                  highlightColor: AppColors.shimmerHighlight,
                  child: Container(color: AppColors.cardBackground),
                ),
                errorWidget: (context, url, error) => Container(
                  color: AppColors.cardBackground,
                  child: const Icon(
                    Icons.broken_image_rounded,
                    color: AppColors.textTertiary,
                  ),
                ),
              ),
              
              // Status overlay
              if (photo.isProcessing)
                Container(
                  color: Colors.black54,
                  child: const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primary,
                    ),
                  ),
                ),
              
              // Edit type badge
              if (photo.editType != EditType.none)
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _getEditTypeName(photo.editType),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  String _getEditTypeName(EditType type) {
    switch (type) {
      case EditType.enhance:
        return 'Enhanced';
      case EditType.restore:
        return 'Restored';
      case EditType.selfieEdit:
        return 'Beautified';
      case EditType.faceSwap:
        return 'Face Swap';
      case EditType.aging:
        return 'Aged';
      case EditType.babyGenerator:
        return 'Baby AI';
      case EditType.animate:
        return 'Animated';
      case EditType.styleTransfer:
        return 'Styled';
      case EditType.upscale:
        return 'Upscaled';
      case EditType.filter:
        return 'Filtered';
      case EditType.none:
        return '';
    }
  }
}





