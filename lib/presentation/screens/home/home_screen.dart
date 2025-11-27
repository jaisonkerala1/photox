import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../config/routes/app_routes.dart';
import '../../../config/theme/app_colors.dart';
import '../../../core/utils/image_picker_util.dart';
import '../../bloc/auth/auth_bloc.dart';
import '../../bloc/auth/auth_state.dart';
import '../../bloc/home/home_bloc.dart';
import '../../bloc/home/home_event.dart';
import '../ai_tools/ai_tools_screen.dart';
import 'mine_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    context.read<HomeBloc>().add(const HomeLoadRequested());
  }

  void _onImageSelected(File image, String editType) {
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
      case 'upscale':
        Navigator.of(context).pushNamed(
          AppRoutes.enhance,
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

  void _pickImageForFeature(String editType) {
    // For enhance, go directly to the screen with demo
    if (editType == 'enhance') {
      Navigator.of(context).pushNamed(AppRoutes.enhance);
      return;
    }
    
    // For other features, show image picker first
    ImagePickerUtil.showImageSourceDialog(
      context,
      onImageSelected: (file) => _onImageSelected(file, editType),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: IndexedStack(
          index: _currentIndex,
          children: [
            _buildHomeContent(),
            const AIToolsScreen(),
            const MineScreen(),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildHomeContent() {
    return CustomScrollView(
      slivers: [
        // Top Bar
        SliverToBoxAdapter(
          child: _buildTopBar(),
        ),

        const SliverToBoxAdapter(child: SizedBox(height: 20)),

        // Feature Cards Row - Quick Actions
        SliverToBoxAdapter(
          child: _buildFeatureCardsRow(),
        ),

        const SliverToBoxAdapter(child: SizedBox(height: 28)),

        // Trending Section
        SliverToBoxAdapter(
          child: _buildSection(
            title: 'Trending',
            items: [
              _ImageCardData('Instant Snap', 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=400&h=600&fit=crop'),
              _ImageCardData('Figurine', 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=400&h=600&fit=crop'),
              _ImageCardData('Ghostface', 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=400&h=600&fit=crop'),
              _ImageCardData('Giant', 'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=400&h=600&fit=crop'),
            ],
          ),
        ),

        const SliverToBoxAdapter(child: SizedBox(height: 24)),

        // Xmas Section
        SliverToBoxAdapter(
          child: _buildSection(
            title: 'Xmas🎄',
            items: [
              _ImageCardData('Cozy Vibes', 'https://images.unsplash.com/photo-1543589077-47d81606c1bf?w=400&h=600&fit=crop'),
              _ImageCardData('Green Trouble', 'https://images.unsplash.com/photo-1482330454287-3cf7e3a7b585?w=400&h=600&fit=crop'),
              _ImageCardData('Snow Globe❄️', 'https://images.unsplash.com/photo-1512474932049-9a2c01e0b389?w=400&h=600&fit=crop'),
              _ImageCardData('Santa', 'https://images.unsplash.com/photo-1576267423048-15c0040fec78?w=400&h=600&fit=crop'),
            ],
          ),
        ),

        const SliverToBoxAdapter(child: SizedBox(height: 24)),

        // For You Section
        SliverToBoxAdapter(
          child: _buildSection(
            title: 'For You',
            items: [
              _ImageCardData('Portrait', 'https://images.unsplash.com/photo-1531746020798-e6953c6e8e04?w=400&h=600&fit=crop'),
              _ImageCardData('Vintage', 'https://images.unsplash.com/photo-1524504388940-b1c1722653e1?w=400&h=600&fit=crop'),
              _ImageCardData('Neon', 'https://images.unsplash.com/photo-1529626455594-4ff0802cfb7e?w=400&h=600&fit=crop'),
              _ImageCardData('Artistic', 'https://images.unsplash.com/photo-1488426862026-3ee34a7d66df?w=400&h=600&fit=crop'),
            ],
          ),
        ),

        const SliverToBoxAdapter(child: SizedBox(height: 24)),
      ],
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          // Settings Icon
          GestureDetector(
            onTap: () {
              setState(() => _currentIndex = 2);
            },
            child: Container(
              padding: const EdgeInsets.all(8),
              child: Icon(
                Icons.settings_outlined,
                size: 24,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Title
          Text(
            'Home',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const Spacer(),
          // PRO Button
          BlocBuilder<AuthBloc, AuthState>(
            builder: (context, state) {
              return GestureDetector(
                onTap: () => Navigator.of(context).pushNamed(AppRoutes.subscription),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF7C3AED), Color(0xFFA855F7)],
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.shopping_bag_outlined,
                        size: 18,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'PRO',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    ).animate().fadeIn().slideY(begin: -0.1);
  }

  Widget _buildFeatureCardsRow() {
    return SizedBox(
      height: 100,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          _CircularFeatureButton(
            icon: Icons.auto_awesome,
            label: 'AI Enhancer',
            onTap: () => _pickImageForFeature('enhance'),
          ),
          _CircularFeatureButton(
            icon: Icons.photo_filter_outlined,
            label: 'Restore Old',
            onTap: () => _pickImageForFeature('restore'),
          ),
          _CircularFeatureButton(
            icon: Icons.face_retouching_natural,
            label: 'Perfect Selfie',
            onTap: () => _pickImageForFeature('style'),
          ),
          _CircularFeatureButton(
            icon: Icons.child_care_rounded,
            label: 'AI Baby',
            onTap: () => _pickImageForFeature('style'),
          ),
          _CircularFeatureButton(
            icon: Icons.elderly_rounded,
            label: 'AI Aging',
            onTap: () => _pickImageForFeature('aging'),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 100.ms);
  }

  Widget _buildSection({
    required String title,
    required List<_ImageCardData> items,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              GestureDetector(
                onTap: () {},
                child: Row(
                  children: [
                    Text(
                      'See All',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF7C3AED),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.chevron_right,
                      size: 20,
                      color: Color(0xFF7C3AED),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        // Image Cards
        SizedBox(
          height: 180,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: items.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: EdgeInsets.only(right: index < items.length - 1 ? 10 : 0),
                child: _ImageCard(
                  label: items[index].label,
                  imageUrl: items[index].imageUrl,
                  onTap: () => _pickImageForFeature('style'),
                ),
              );
            },
          ),
        ),
      ],
    ).animate().fadeIn(delay: 200.ms);
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(
          top: BorderSide(color: AppColors.cardBorder, width: 1),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavItem(
                icon: Icons.home_rounded,
                label: 'Home',
                isSelected: _currentIndex == 0,
                onTap: () => setState(() => _currentIndex = 0),
              ),
              _NavItem(
                icon: Icons.auto_fix_high,
                label: 'AI Tools',
                isSelected: _currentIndex == 1,
                onTap: () => setState(() => _currentIndex = 1),
              ),
              _NavItem(
                icon: Icons.person_outline,
                label: 'Mine',
                isSelected: _currentIndex == 2,
                onTap: () => setState(() => _currentIndex = 2),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ImageCardData {
  final String label;
  final String imageUrl;

  _ImageCardData(this.label, this.imageUrl);
}

class _CircularFeatureButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _CircularFeatureButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 20),
      child: GestureDetector(
        onTap: onTap,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Flat circular button - black & white minimal
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.cardBackground,
                border: Border.all(
                  color: AppColors.cardBorder,
                  width: 1.5,
                ),
              ),
              child: Icon(
                icon,
                size: 26,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            // Label
            SizedBox(
              width: 70,
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ImageCard extends StatelessWidget {
  final String label;
  final String imageUrl;
  final VoidCallback onTap;

  const _ImageCard({
    required this.label,
    required this.imageUrl,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 120,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: AppColors.cardBackground,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Network image
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: CachedNetworkImage(
                imageUrl: imageUrl,
                width: double.infinity,
                height: double.infinity,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color(0xFF7C3AED).withOpacity(0.4),
                        Color(0xFFA855F7).withOpacity(0.2),
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
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color(0xFF7C3AED).withOpacity(0.4),
                        Color(0xFFA855F7).withOpacity(0.2),
                        AppColors.cardBackground,
                      ],
                    ),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.image_outlined,
                      size: 48,
                      color: AppColors.textTertiary.withOpacity(0.5),
                    ),
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
                height: 60,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(12),
                    bottomRight: Radius.circular(12),
                  ),
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
              bottom: 8,
              left: 8,
              right: 8,
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                  shadows: [
                    Shadow(
                      color: Colors.black.withOpacity(0.5),
                      blurRadius: 4,
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final activeColor = Color(0xFF7C3AED);
    
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(
          horizontal: isSelected ? 16 : 12,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: isSelected ? activeColor.withOpacity(0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? activeColor : AppColors.textTertiary,
              size: 24,
            ),
            if (isSelected) ...[
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: activeColor,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
