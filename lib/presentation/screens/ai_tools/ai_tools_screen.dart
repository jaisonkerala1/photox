import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../config/routes/app_routes.dart';
import '../../../config/theme/app_colors.dart';
import '../../../core/utils/image_picker_util.dart';
import '../../widgets/feature_card.dart';

class AIToolsScreen extends StatelessWidget {
  const AIToolsScreen({super.key});

  void _pickImageForFeature(BuildContext context, String editType) {
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
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'AI Tools',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ).animate().fadeIn().slideX(begin: -0.1),
          
          const SizedBox(height: 8),
          
          Text(
            'Transform your photos with AI magic',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: AppColors.textSecondary,
            ),
          ).animate().fadeIn(delay: 100.ms),
          
          const SizedBox(height: 24),
          
          // Photo Enhancement Section
          _buildSection(
            context,
            title: 'Photo Enhancement',
            children: [
              Row(
                children: [
                  Expanded(
                    child: FeatureCard(
                      icon: Icons.auto_awesome_rounded,
                      title: 'Enhance',
                      description: 'Improve quality',
                      gradient: AppColors.primaryGradient,
                      onTap: () => _pickImageForFeature(context, 'enhance'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FeatureCard(
                      icon: Icons.hd_rounded,
                      title: 'HD Upscale',
                      description: '4x resolution',
                      gradient: const [Color(0xFF00E676), Color(0xFF00C853)],
                      onTap: () => _pickImageForFeature(context, 'upscale'),
                    ),
                  ),
                ],
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Photo Restoration Section
          _buildSection(
            context,
            title: 'Photo Restoration',
            children: [
              Row(
                children: [
                  Expanded(
                    child: FeatureCard(
                      icon: Icons.restore_rounded,
                      title: 'Restore',
                      description: 'Fix old photos',
                      gradient: AppColors.accentGradient,
                      onTap: () => _pickImageForFeature(context, 'restore'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FeatureCard(
                      icon: Icons.colorize_rounded,
                      title: 'Colorize',
                      description: 'Add colors',
                      gradient: const [Color(0xFFFF9A9E), Color(0xFFFAD0C4)],
                      onTap: () => _pickImageForFeature(context, 'restore'),
                    ),
                  ),
                ],
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Face Tools Section
          _buildSection(
            context,
            title: 'Face Tools',
            children: [
              Row(
                children: [
                  Expanded(
                    child: FeatureCard(
                      icon: Icons.face_retouching_natural,
                      title: 'Face Swap',
                      description: 'Swap faces',
                      gradient: AppColors.purpleGradient,
                      isPro: true,
                      onTap: () => Navigator.of(context).pushNamed(AppRoutes.faceSwap),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FeatureCard(
                      icon: Icons.elderly_rounded,
                      title: 'AI Aging',
                      description: 'See your future',
                      gradient: AppColors.proGradient,
                      isPro: true,
                      onTap: () => _pickImageForFeature(context, 'aging'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: FeatureCard(
                      icon: Icons.child_care_rounded,
                      title: 'Baby AI',
                      description: 'Predict babies',
                      gradient: const [Color(0xFFFF6B6B), Color(0xFFE84545)],
                      isPro: true,
                      onTap: () {},
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FeatureCard(
                      icon: Icons.face_rounded,
                      title: 'Beauty',
                      description: 'Perfect selfies',
                      gradient: const [Color(0xFFFECEFF), Color(0xFFE9B7ED)],
                      onTap: () => _pickImageForFeature(context, 'beauty'),
                    ),
                  ),
                ],
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Creative Section
          _buildSection(
            context,
            title: 'Creative Styles',
            children: [
              Row(
                children: [
                  Expanded(
                    child: FeatureCard(
                      icon: Icons.palette_rounded,
                      title: 'Art Styles',
                      description: 'Transform style',
                      gradient: const [Color(0xFF667EEA), Color(0xFF764BA2)],
                      onTap: () => _pickImageForFeature(context, 'style'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FeatureCard(
                      icon: Icons.filter_vintage_rounded,
                      title: 'Filters',
                      description: 'Trending effects',
                      gradient: const [Color(0xFF4FC3F7), Color(0xFF00B0FF)],
                      onTap: () => _pickImageForFeature(context, 'filter'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: FeatureCard(
                      icon: Icons.animation_rounded,
                      title: 'Animate',
                      description: 'Add motion',
                      gradient: const [Color(0xFFFF6B6B), Color(0xFFFF8E53)],
                      isPro: true,
                      onTap: () {},
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FeatureCard(
                      icon: Icons.toys_rounded,
                      title: 'Figurine',
                      description: '3D toy style',
                      gradient: const [Color(0xFF11998E), Color(0xFF38EF7D)],
                      onTap: () => _pickImageForFeature(context, 'figurine'),
                    ),
                  ),
                ],
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Trending Filters Section
          _buildSection(
            context,
            title: 'Trending Filters',
            children: [
              SizedBox(
                height: 120,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    _TrendingFilterCard(
                      name: 'Instant Snap',
                      gradient: const [Color(0xFFFF6B6B), Color(0xFFFF8E53)],
                      onTap: () {},
                    ),
                    _TrendingFilterCard(
                      name: 'Ghostface',
                      gradient: const [Color(0xFF2C3E50), Color(0xFF4CA1AF)],
                      onTap: () {},
                    ),
                    _TrendingFilterCard(
                      name: 'Snow Globe',
                      gradient: const [Color(0xFF74EBD5), Color(0xFFACB6E5)],
                      onTap: () {},
                    ),
                    _TrendingFilterCard(
                      name: 'Cozy Vibes',
                      gradient: const [Color(0xFFFF9A9E), Color(0xFFFAD0C4)],
                      onTap: () {},
                    ),
                    _TrendingFilterCard(
                      name: 'Santa',
                      gradient: const [Color(0xFFE53935), Color(0xFF43A047)],
                      onTap: () {},
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 12),
        ...children,
      ],
    ).animate().fadeIn(delay: 200.ms);
  }
}

class _TrendingFilterCard extends StatelessWidget {
  final String name;
  final List<Color> gradient;
  final VoidCallback onTap;

  const _TrendingFilterCard({
    required this.name,
    required this.gradient,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 100,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradient,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Stack(
          children: [
            Positioned(
              bottom: 8,
              left: 8,
              right: 8,
              child: Text(
                name,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}


