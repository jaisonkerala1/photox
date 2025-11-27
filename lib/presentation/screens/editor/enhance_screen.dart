import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../config/theme/app_colors.dart';
import '../../../core/utils/image_picker_util.dart';
import '../../bloc/enhance/enhance_bloc.dart';
import '../../bloc/enhance/enhance_event.dart';
import '../../bloc/enhance/enhance_state.dart';

class EnhanceScreen extends StatelessWidget {
  final String? imagePath;

  const EnhanceScreen({
    super.key,
    this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        final bloc = EnhanceBloc();
        if (imagePath != null && imagePath!.isNotEmpty) {
          bloc.add(EnhanceImageLoaded(imagePath!));
        }
        return bloc;
      },
      child: const _EnhanceScreenContent(),
    );
  }
}

class _EnhanceScreenContent extends StatefulWidget {
  const _EnhanceScreenContent();

  @override
  State<_EnhanceScreenContent> createState() => _EnhanceScreenContentState();
}

class _EnhanceScreenContentState extends State<_EnhanceScreenContent> {
  // Demo images from Unsplash
  static const String _demoBeforeUrl = 
      'https://images.unsplash.com/photo-1531746020798-e6953c6e8e04?w=800&h=1200&fit=crop&q=60&sat=-30&bri=-10';
  static const String _demoAfterUrl = 
      'https://images.unsplash.com/photo-1531746020798-e6953c6e8e04?w=800&h=1200&fit=crop&q=100';

  double _demoSliderPosition = 0.5;
  bool _isUsingDemo = true;
  double _brightness = 0.0; // -1.0 to 1.0, 0 is normal

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<EnhanceBloc, EnhanceState>(
      listener: (context, state) {
        if (state.originalImagePath != null) {
          setState(() => _isUsingDemo = false);
        }
        if (state.isSaved) {
          _showSuccessSnackbar(context);
        }
        if (state.hasError && state.errorMessage != null) {
          _showErrorSnackbar(context, state.errorMessage!);
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: AppColors.background,
          body: SafeArea(
            child: Column(
              children: [
                // Top Bar
                _buildTopBar(context, state),

                // Main Content
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        const SizedBox(height: 16),
                        
                        // Image Comparison Area
                        _buildImageArea(context, state),

                        const SizedBox(height: 20),

                        // Enhancement Type Pills
                        _buildEnhanceTypePills(context, state),

                        const SizedBox(height: 20),

                        // Brightness Control (only show after enhancement)
                        if (state.isEnhanced && !_isUsingDemo)
                          _buildBrightnessControl(),

                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),

                // Bottom Action Area
                _buildBottomActions(context, state),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTopBar(BuildContext context, EnhanceState state) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Row(
        children: [
          // Back Button
          _buildIconButton(
            icon: Icons.arrow_back_ios_new_rounded,
            onTap: () => Navigator.of(context).pop(),
          ),

          const Spacer(),

          // Title with subtle animation
          Column(
            children: [
              Text(
                'AI Enhancer',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              if (_isUsingDemo)
                Text(
                  'Try the demo below',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.textTertiary,
                  ),
                ).animate(onPlay: (c) => c.repeat(reverse: true))
                  .fadeIn(duration: 1500.ms)
                  .then()
                  .fadeOut(duration: 1500.ms),
            ],
          ),

          const Spacer(),

          // Share Button (visible after enhancement)
          if (state.isEnhanced && !_isUsingDemo)
            _buildIconButton(
              icon: Icons.share_rounded,
              onTap: () => _shareImage(context, state),
              isPrimary: true,
            ).animate().fadeIn().scale()
          else
            const SizedBox(width: 48),
        ],
      ),
    ).animate().fadeIn().slideY(begin: -0.2);
  }

  Widget _buildIconButton({
    required IconData icon,
    required VoidCallback onTap,
    bool isPrimary = false,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: isPrimary ? Color(0xFF7C3AED) : AppColors.cardBackground,
          borderRadius: BorderRadius.circular(14),
          border: isPrimary ? null : Border.all(color: AppColors.cardBorder),
        ),
        child: Icon(
          icon,
          color: isPrimary ? Colors.white : AppColors.textPrimary,
          size: 20,
        ),
      ),
    );
  }

  Widget _buildImageArea(BuildContext context, EnhanceState state) {
    final screenWidth = MediaQuery.of(context).size.width;
    final imageHeight = screenWidth * 1.2;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      height: imageHeight,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Color(0xFF7C3AED).withOpacity(0.15),
            blurRadius: 40,
            offset: const Offset(0, 20),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Image Comparison
          ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: _isUsingDemo
                ? _buildDemoComparison(screenWidth, imageHeight)
                : _buildUserImageComparison(context, state, screenWidth, imageHeight),
          ),

          // Demo Badge
          if (_isUsingDemo)
            Positioned(
              top: 16,
              left: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withOpacity(0.2)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.play_circle_outline, size: 14, color: Colors.white),
                    const SizedBox(width: 6),
                    Text(
                      'DEMO',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(delay: 500.ms).slideX(begin: -0.2),
            ),

          // Processing Overlay
          if (state.isProcessing)
            _buildProcessingOverlay(state),

          // Enhanced Badge
          if (state.isEnhanced && !_isUsingDemo)
            Positioned(
              top: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF7C3AED), Color(0xFFA855F7)],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.auto_awesome, size: 14, color: Colors.white),
                    const SizedBox(width: 6),
                    Text(
                      'ENHANCED',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn().scale(),
            ),

          // Slider Handle & Line
          if ((_isUsingDemo || state.isEnhanced) && !state.isProcessing)
            _buildSliderOverlay(context, state, screenWidth, imageHeight),

          // Labels
          if ((_isUsingDemo || state.isEnhanced) && !state.isProcessing)
            _buildComparisonLabels(),
        ],
      ),
    ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1);
  }

  Widget _buildDemoComparison(double width, double height) {
    final sliderX = _demoSliderPosition * width;

    return Stack(
      children: [
        // Before Image (Full)
        CachedNetworkImage(
          imageUrl: _demoBeforeUrl,
          width: width,
          height: height,
          fit: BoxFit.cover,
          placeholder: (context, url) => _buildImagePlaceholder(),
          errorWidget: (context, url, error) => _buildImagePlaceholder(),
        ),

        // After Image (Clipped)
        ClipRect(
          clipper: _RectClipper(sliderX),
          child: CachedNetworkImage(
            imageUrl: _demoAfterUrl,
            width: width,
            height: height,
            fit: BoxFit.cover,
            placeholder: (context, url) => const SizedBox(),
            errorWidget: (context, url, error) => const SizedBox(),
          ),
        ),
      ],
    );
  }

  Widget _buildUserImageComparison(
    BuildContext context,
    EnhanceState state,
    double width,
    double height,
  ) {
    if (state.originalImagePath == null) {
      return _buildImagePlaceholder();
    }

    final sliderX = state.comparisonPosition * width;

    return Stack(
      children: [
        // Original Image (Full)
        Image.file(
          File(state.originalImagePath!),
          width: width,
          height: height,
          fit: BoxFit.cover,
        ),

        // Enhanced Image (Clipped) with brightness adjustment
        if (state.isEnhanced && state.enhancedImagePath != null)
          ClipRect(
            clipper: _RectClipper(sliderX),
            child: ColorFiltered(
              colorFilter: ColorFilter.matrix(_brightnessMatrix(_brightness)),
              child: Image.file(
                File(state.enhancedImagePath!),
                width: width,
                height: height,
                fit: BoxFit.cover,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildSliderOverlay(
    BuildContext context,
    EnhanceState state,
    double width,
    double height,
  ) {
    final position = _isUsingDemo ? _demoSliderPosition : state.comparisonPosition;
    final sliderX = position * width;

    return Stack(
      children: [
        // Full-area gesture detector for dragging anywhere on the image
        Positioned.fill(
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onHorizontalDragStart: (details) {
              _handleDrag(context, state, details.localPosition.dx, width);
            },
            onHorizontalDragUpdate: (details) {
              _handleDrag(context, state, details.localPosition.dx, width);
            },
            onTapDown: (details) {
              _handleDrag(context, state, details.localPosition.dx, width);
            },
          ),
        ),
        
        // Slider Line and Handles
        Positioned(
          left: sliderX - 22, // Center the 44px handle
          top: 0,
          bottom: 0,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onHorizontalDragStart: (details) {
              HapticFeedback.selectionClick();
            },
            onHorizontalDragUpdate: (details) {
              final newX = sliderX + details.delta.dx;
              _handleDrag(context, state, newX, width);
            },
            child: SizedBox(
              width: 44,
              child: Column(
                children: [
                  // Top Handle
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.chevron_left, size: 16, color: AppColors.background),
                        Icon(Icons.chevron_right, size: 16, color: AppColors.background),
                      ],
                    ),
                  ),
                  
                  // Vertical Line
                  Expanded(
                    child: Center(
                      child: Container(
                        width: 3,
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
                  
                  // Bottom Handle
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.chevron_left, size: 16, color: AppColors.background),
                        Icon(Icons.chevron_right, size: 16, color: AppColors.background),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _handleDrag(BuildContext context, EnhanceState state, double localX, double width) {
    final newPosition = (localX / width).clamp(0.0, 1.0);
    
    if (_isUsingDemo) {
      setState(() {
        _demoSliderPosition = newPosition;
      });
    } else if (state.isEnhanced) {
      context.read<EnhanceBloc>().add(EnhanceComparisonChanged(newPosition));
    }
    
    // Continuous haptic feedback on every movement
    HapticFeedback.selectionClick();
  }

  Widget _buildComparisonLabels() {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 16,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16),
            child: _buildLabel('Before'),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: _buildLabel('After'),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildProcessingOverlay(EnhanceState state) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: Colors.black.withOpacity(0.7),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Animated Progress Ring
            SizedBox(
              width: 100,
              height: 100,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Background ring
                  CircularProgressIndicator(
                    value: 1,
                    strokeWidth: 4,
                    backgroundColor: Colors.white.withOpacity(0.1),
                    valueColor: AlwaysStoppedAnimation(Colors.white.withOpacity(0.1)),
                  ),
                  // Progress ring
                  CircularProgressIndicator(
                    value: state.progress,
                    strokeWidth: 4,
                    backgroundColor: Colors.transparent,
                    valueColor: AlwaysStoppedAnimation(Color(0xFF7C3AED)),
                  ),
                  // Percentage
                  Text(
                    '${(state.progress * 100).toInt()}%',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Enhancing...',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'AI is working its magic ✨',
              style: TextStyle(
                fontSize: 13,
                color: Colors.white.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      color: AppColors.cardBackground,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(
              strokeWidth: 2,
              color: Color(0xFF7C3AED),
            ),
            const SizedBox(height: 16),
            Text(
              'Loading demo...',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEnhanceTypePills(BuildContext context, EnhanceState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            'Enhancement Mode',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 44,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            children: EnhanceType.values.map((type) {
              final isSelected = state.enhanceType == type;
              return Padding(
                padding: const EdgeInsets.only(right: 10),
                child: GestureDetector(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    context.read<EnhanceBloc>().add(EnhanceTypeChanged(type));
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    decoration: BoxDecoration(
                      gradient: isSelected
                          ? LinearGradient(colors: [Color(0xFF7C3AED), Color(0xFFA855F7)])
                          : null,
                      color: isSelected ? null : AppColors.cardBackground,
                      borderRadius: BorderRadius.circular(22),
                      border: isSelected ? null : Border.all(color: AppColors.cardBorder),
                    ),
                    child: Center(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _getTypeIcon(type),
                            size: 16,
                            color: isSelected ? Colors.white : AppColors.textSecondary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _getTypeName(type),
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                              color: isSelected ? Colors.white : AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    ).animate().fadeIn(delay: 300.ms);
  }

  IconData _getTypeIcon(EnhanceType type) {
    switch (type) {
      case EnhanceType.auto:
        return Icons.auto_awesome;
      case EnhanceType.portrait:
        return Icons.face;
      case EnhanceType.landscape:
        return Icons.landscape;
      case EnhanceType.lowLight:
        return Icons.nightlight_round;
      case EnhanceType.hdr:
        return Icons.hdr_on;
    }
  }

  String _getTypeName(EnhanceType type) {
    switch (type) {
      case EnhanceType.auto:
        return 'Auto';
      case EnhanceType.portrait:
        return 'Portrait';
      case EnhanceType.landscape:
        return 'Landscape';
      case EnhanceType.lowLight:
        return 'Low Light';
      case EnhanceType.hdr:
        return 'HDR';
    }
  }

  Widget _buildBrightnessControl() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.brightness_6_rounded,
                    size: 18,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Brightness',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Color(0xFF7C3AED).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _brightness == 0 
                      ? '0' 
                      : (_brightness > 0 ? '+${(_brightness * 100).toInt()}' : '${(_brightness * 100).toInt()}'),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF7C3AED),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SliderTheme(
            data: SliderThemeData(
              activeTrackColor: Color(0xFF7C3AED),
              inactiveTrackColor: AppColors.cardBorder,
              thumbColor: Colors.white,
              overlayColor: Color(0xFF7C3AED).withOpacity(0.2),
              trackHeight: 6,
              thumbShape: const RoundSliderThumbShape(
                enabledThumbRadius: 10,
                elevation: 4,
              ),
            ),
            child: Slider(
              value: _brightness,
              min: -0.5,
              max: 0.5,
              onChanged: (value) {
                setState(() {
                  _brightness = value;
                });
                HapticFeedback.selectionClick();
              },
            ),
          ),
          // Quick preset buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildBrightnessPreset('Dark', -0.3),
              _buildBrightnessPreset('Normal', 0.0),
              _buildBrightnessPreset('Bright', 0.3),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(delay: 400.ms);
  }

  Widget _buildBrightnessPreset(String label, double value) {
    final isSelected = (_brightness - value).abs() < 0.05;
    return GestureDetector(
      onTap: () {
        setState(() {
          _brightness = value;
        });
        HapticFeedback.selectionClick();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Color(0xFF7C3AED).withOpacity(0.2) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? Color(0xFF7C3AED) : AppColors.cardBorder,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            color: isSelected ? Color(0xFF7C3AED) : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _buildBottomActions(BuildContext context, EnhanceState state) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: _isUsingDemo
            ? _buildSelectPhotoButton(context)
            : _buildEnhanceActions(context, state),
      ),
    ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.2);
  }

  Widget _buildSelectPhotoButton(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Main CTA
        GestureDetector(
          onTap: () => _selectImage(context),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 18),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF7C3AED), Color(0xFFA855F7)],
              ),
              borderRadius: BorderRadius.circular(30), // Pill shaped
              boxShadow: [
                BoxShadow(
                  color: Color(0xFF7C3AED).withOpacity(0.4),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.add_photo_alternate_rounded, color: Colors.white, size: 22),
                const SizedBox(width: 10),
                Text(
                  'Select Your Photo',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        // Hint text
        Text(
          'Drag the slider above to see the magic ✨',
          style: TextStyle(
            fontSize: 13,
            color: AppColors.textTertiary,
          ),
        ),
      ],
    );
  }

  Widget _buildEnhanceActions(BuildContext context, EnhanceState state) {
    return Row(
      children: [
        // Reset / Change Photo Button
        Expanded(
          child: GestureDetector(
            onTap: () {
              HapticFeedback.mediumImpact();
              if (state.isEnhanced) {
                setState(() {
                  _brightness = 0.0; // Reset brightness
                });
                context.read<EnhanceBloc>().add(const EnhanceReset());
              } else {
                _selectImage(context);
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                borderRadius: BorderRadius.circular(30), // Pill shaped
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: Center(
                child: Text(
                  state.isEnhanced ? 'Reset' : 'Change',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        // Enhance / Save Button
        Expanded(
          flex: 2,
          child: GestureDetector(
            onTap: state.isProcessing
                ? null
                : () {
                    HapticFeedback.mediumImpact();
                    if (state.isEnhanced) {
                      context.read<EnhanceBloc>().add(EnhanceSaveRequested(brightness: _brightness));
                    } else {
                      context.read<EnhanceBloc>().add(const EnhanceRequested());
                    }
                  },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                gradient: state.isProcessing
                    ? null
                    : LinearGradient(colors: [Color(0xFF7C3AED), Color(0xFFA855F7)]),
                color: state.isProcessing ? AppColors.cardBorder : null,
                borderRadius: BorderRadius.circular(30), // Pill shaped
                boxShadow: state.isProcessing
                    ? null
                    : [
                        BoxShadow(
                          color: Color(0xFF7C3AED).withOpacity(0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
              ),
              child: Center(
                child: state.isProcessing
                    ? SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            state.isEnhanced ? Icons.save_rounded : Icons.auto_awesome,
                            color: Colors.white,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            state.isEnhanced ? 'Save Image' : 'Enhance Now',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _selectImage(BuildContext context) {
    ImagePickerUtil.showImageSourceDialog(
      context,
      onImageSelected: (file) {
        context.read<EnhanceBloc>().add(EnhanceImageLoaded(file.path));
      },
    );
  }

  void _shareImage(BuildContext context, EnhanceState state) {
    // Show share options - for now just show a snackbar
    // In production, integrate with share_plus package
    if (state.enhancedImagePath != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.share_rounded, color: Colors.white, size: 20),
              const SizedBox(width: 10),
              Text('Share feature coming soon!'),
            ],
          ),
          backgroundColor: Color(0xFF7C3AED),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(16),
        ),
      );
    }
  }

  void _showSuccessSnackbar(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Text('Image saved to gallery!'),
          ],
        ),
        backgroundColor: Color(0xFF7C3AED),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _showErrorSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  // Create brightness adjustment matrix
  List<double> _brightnessMatrix(double brightness) {
    // brightness: -1.0 to 1.0, where 0 is normal
    final double b = brightness;
    return [
      1, 0, 0, 0, b * 255,
      0, 1, 0, 0, b * 255,
      0, 0, 1, 0, b * 255,
      0, 0, 0, 1, 0,
    ];
  }
}

class _RectClipper extends CustomClipper<Rect> {
  final double clipWidth;

  _RectClipper(this.clipWidth);

  @override
  Rect getClip(Size size) {
    return Rect.fromLTWH(0, 0, clipWidth, size.height);
  }

  @override
  bool shouldReclip(_RectClipper oldClipper) {
    return clipWidth != oldClipper.clipWidth;
  }
}
