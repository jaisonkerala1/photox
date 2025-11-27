import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../config/routes/app_routes.dart';
import '../../../config/theme/app_colors.dart';
import '../../../core/utils/image_picker_util.dart';

class AIToolsScreen extends StatelessWidget {
  const AIToolsScreen({super.key});

  void _pickImageForFeature(BuildContext context, String editType) {
    // For enhance, go directly to the screen with demo
    if (editType == 'enhance') {
      Navigator.of(context).pushNamed(AppRoutes.enhance);
      return;
    }
    
    // For other features, show image picker first
    ImagePickerUtil.showImageSourceDialog(
      context,
      onImageSelected: (file) => _onImageSelected(context, file, editType),
    );
  }

  void _onImageSelected(BuildContext context, File image, String editType) {
    switch (editType) {
      case 'enhance':
        Navigator.of(context).pushNamed(
          AppRoutes.enhance,
          arguments: {'imagePath': image.path},
        );
        break;
      case 'restore':
        Navigator.of(context).pushNamed(
          AppRoutes.restore,
          arguments: {'imagePath': image.path},
        );
        break;
      case 'aging':
        Navigator.of(context).pushNamed(
          AppRoutes.aging,
          arguments: {'imagePath': image.path},
        );
        break;
      case 'style':
        Navigator.of(context).pushNamed(
          AppRoutes.styleTransfer,
          arguments: {'imagePath': image.path},
        );
        break;
      case 'filter':
        Navigator.of(context).pushNamed(
          AppRoutes.filter,
          arguments: {'imagePath': image.path},
        );
        break;
      default:
        Navigator.of(context).pushNamed(
          AppRoutes.editor,
          arguments: {'imagePath': image.path},
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Bar
          _buildTopBar(context),
          
          const SizedBox(height: 16),
          
          // Before/After Cards and Feature Cards
          _BeforeAfterCard(
            label: 'AI Enhancer',
            beforeImageUrl: 'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=400&h=300&fit=crop&q=60',
            afterImageUrl: 'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=400&h=300&fit=crop&q=100',
            onTap: () => _pickImageForFeature(context, 'enhance'),
          ).animate().fadeIn().slideY(begin: 0.1),
          
          const SizedBox(height: 16),
          
          _BeforeAfterCard(
            label: 'Restore Old Photo',
            beforeImageUrl: 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=400&h=300&fit=crop&sat=-100',
            afterImageUrl: 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=400&h=300&fit=crop',
            onTap: () => _pickImageForFeature(context, 'restore'),
          ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.1),
          
          const SizedBox(height: 16),
          
          _FullWidthFeatureCard(
            label: 'Perfect Selfie',
            imageUrl: 'https://images.unsplash.com/photo-1531746020798-e6953c6e8e04?w=800&h=450&fit=crop',
            showSparkles: true,
            onTap: () => _pickImageForFeature(context, 'style'),
          ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1),
          
          const SizedBox(height: 16),
          
          _FullWidthFeatureCard(
            label: 'AI Baby Generator',
            imageUrl: 'https://images.unsplash.com/photo-1519689680058-324335c77eba?w=800&h=450&fit=crop',
            showSparkles: true,
            isPro: true,
            onTap: () => _pickImageForFeature(context, 'style'),
          ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.1),
          
          const SizedBox(height: 16),
          
          _FullWidthFeatureCard(
            label: 'AI Aging Simulator',
            imageUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=800&h=450&fit=crop',
            showSparkles: true,
            isPro: true,
            onTap: () => _pickImageForFeature(context, 'aging'),
          ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.1),
          
          const SizedBox(height: 16),
          
          _BeforeAfterCard(
            label: 'Face Swap',
            beforeImageUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=400&h=300&fit=crop',
            afterImageUrl: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=400&h=300&fit=crop',
            isPro: true,
            onTap: () => Navigator.of(context).pushNamed(AppRoutes.faceSwap),
          ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.1),
          
          const SizedBox(height: 16),
          
          _BeforeAfterCard(
            label: 'Colorize',
            beforeImageUrl: 'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=400&h=300&fit=crop&sat=-100',
            afterImageUrl: 'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=400&h=300&fit=crop',
            onTap: () => _pickImageForFeature(context, 'restore'),
          ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.1),
          
          const SizedBox(height: 140),
        ],
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          // Settings Icon
          Container(
            padding: const EdgeInsets.all(8),
            child: Icon(
              Icons.settings_outlined,
              size: 28,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(width: 12),
          // Title
          Text(
            'AI Tools',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const Spacer(),
          // PRO Button
          GestureDetector(
            onTap: () => Navigator.of(context).pushNamed(AppRoutes.subscription),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF7C3AED), Color(0xFFA855F7)],
                ),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.shopping_bag_outlined,
                    size: 16,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'PRO',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn().slideY(begin: -0.1);
  }
}

/// Before/After comparison card with split view
class _BeforeAfterCard extends StatelessWidget {
  final String label;
  final String beforeImageUrl;
  final String afterImageUrl;
  final bool isPro;
  final VoidCallback onTap;

  const _BeforeAfterCard({
    required this.label,
    required this.beforeImageUrl,
    required this.afterImageUrl,
    this.isPro = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        height: 200,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.12),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            children: [
              // Split background with images
              Row(
                children: [
                  // Left side (Before)
                  Expanded(
                    child: CachedNetworkImage(
                      imageUrl: beforeImageUrl,
                      fit: BoxFit.cover,
                      height: double.infinity,
                      placeholder: (context, url) => Container(
                        color: AppColors.cardBackground,
                        child: Center(
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Color(0xFF7C3AED),
                          ),
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: AppColors.cardBackground,
                        child: Icon(Icons.image_outlined, size: 40, color: AppColors.textTertiary),
                      ),
                    ),
                  ),
                  // Right side (After)
                  Expanded(
                    child: CachedNetworkImage(
                      imageUrl: afterImageUrl,
                      fit: BoxFit.cover,
                      height: double.infinity,
                      placeholder: (context, url) => Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Color(0xFF7C3AED).withOpacity(0.3),
                              Color(0xFFA855F7).withOpacity(0.4),
                            ],
                          ),
                        ),
                        child: Center(
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: AppColors.surfaceVariant,
                        child: Icon(Icons.auto_awesome, size: 40, color: Colors.white70),
                      ),
                    ),
                  ),
                ],
              ),
              // Center divider
              Positioned(
                left: 0,
                right: 0,
                top: 0,
                bottom: 0,
                child: Center(
                  child: Container(
                    width: 3,
                    height: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              // Gradient overlay at bottom
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: 80,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.7),
                      ],
                    ),
                  ),
                ),
              ),
              // Label
              Positioned(
                bottom: 20,
                left: 20,
                child: Row(
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            color: Colors.black.withOpacity(0.4),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                    ),
                    if (isPro) ...[
                      const SizedBox(width: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFFFD700), Color(0xFFFF8C00)],
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'PRO',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Full width feature card with single image
class _FullWidthFeatureCard extends StatelessWidget {
  final String label;
  final String imageUrl;
  final bool showSparkles;
  final bool isPro;
  final VoidCallback onTap;

  const _FullWidthFeatureCard({
    required this.label,
    required this.imageUrl,
    this.showSparkles = false,
    this.isPro = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        height: 200,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.12),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            children: [
              // Background image
              CachedNetworkImage(
                imageUrl: imageUrl,
                width: double.infinity,
                height: double.infinity,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFF7C3AED).withOpacity(0.4),
                        Color(0xFFA855F7).withOpacity(0.3),
                        AppColors.cardBackground,
                      ],
                    ),
                  ),
                  child: Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Color(0xFF7C3AED),
                    ),
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFF7C3AED).withOpacity(0.4),
                        Color(0xFFA855F7).withOpacity(0.3),
                        AppColors.cardBackground,
                      ],
                    ),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.image_outlined,
                      size: 48,
                      color: AppColors.textTertiary,
                    ),
                  ),
                ),
              ),
              // Sparkles decoration
              if (showSparkles)
                Positioned(
                  top: 20,
                  right: 20,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.auto_awesome,
                      size: 28,
                      color: Colors.white,
                    ),
                  ),
                ),
              // Gradient overlay at bottom
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: 80,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.7),
                      ],
                    ),
                  ),
                ),
              ),
              // Label
              Positioned(
                bottom: 20,
                left: 20,
                child: Row(
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            color: Colors.black.withOpacity(0.4),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                    ),
                    if (isPro) ...[
                      const SizedBox(width: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFFFD700), Color(0xFFFF8C00)],
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'PRO',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
