import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../config/theme/app_colors.dart';

class ComparisonSlider extends StatefulWidget {
  final String beforeImagePath;
  final String? afterImagePath;
  final double position;
  final ValueChanged<double> onPositionChanged;
  final bool isProcessing;
  final double progress;

  const ComparisonSlider({
    super.key,
    required this.beforeImagePath,
    this.afterImagePath,
    required this.position,
    required this.onPositionChanged,
    this.isProcessing = false,
    this.progress = 0.0,
  });

  @override
  State<ComparisonSlider> createState() => _ComparisonSliderState();
}

class _ComparisonSliderState extends State<ComparisonSlider>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _pulseAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    if (widget.isProcessing) {
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(ComparisonSlider oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isProcessing && !oldWidget.isProcessing) {
      _pulseController.repeat(reverse: true);
    } else if (!widget.isProcessing && oldWidget.isProcessing) {
      _pulseController.stop();
      _pulseController.reset();
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final height = constraints.maxHeight;

        return GestureDetector(
          onHorizontalDragUpdate: (details) {
            if (widget.afterImagePath == null) return;
            final newPosition = (details.localPosition.dx / width).clamp(0.0, 1.0);
            HapticFeedback.selectionClick();
            widget.onPositionChanged(newPosition);
          },
          child: Stack(
            children: [
              // Before Image (Full)
              Positioned.fill(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: ColorFiltered(
                    colorFilter: ColorFilter.mode(
                      Colors.black.withOpacity(0.1),
                      BlendMode.darken,
                    ),
                    child: Image.file(
                      File(widget.beforeImagePath),
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: AppColors.cardBackground,
                        child: Center(
                          child: Icon(
                            Icons.image_not_supported_outlined,
                            size: 64,
                            color: AppColors.textTertiary,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // After Image (Clipped)
              if (widget.afterImagePath != null)
                Positioned.fill(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: ClipRect(
                      clipper: _ImageClipper(widget.position * width),
                      child: Image.file(
                        File(widget.afterImagePath!),
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: AppColors.cardBackground,
                        ),
                      ),
                    ),
                  ),
                ),

              // Processing Overlay
              if (widget.isProcessing)
                Positioned.fill(
                  child: AnimatedBuilder(
                    animation: _pulseAnimation,
                    builder: (context, child) {
                      return Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Color(0xFF7C3AED).withOpacity(
                              0.3 + (_pulseAnimation.value * 0.4),
                            ),
                            width: 2,
                          ),
                        ),
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Circular Progress
                              SizedBox(
                                width: 80,
                                height: 80,
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    CircularProgressIndicator(
                                      value: widget.progress,
                                      strokeWidth: 3,
                                      backgroundColor: Colors.white.withOpacity(0.2),
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Color(0xFF7C3AED),
                                      ),
                                    ),
                                    Text(
                                      '${(widget.progress * 100).toInt()}%',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Enhancing...',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),

              // Comparison Divider Line
              if (widget.afterImagePath != null && !widget.isProcessing)
                Positioned(
                  left: widget.position * width - 1.5,
                  top: 0,
                  bottom: 0,
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

              // Drag Handle
              if (widget.afterImagePath != null && !widget.isProcessing)
                Positioned(
                  left: widget.position * width - 20,
                  top: height / 2 - 20,
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
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
                ),

              // Before/After Labels
              if (widget.afterImagePath != null && !widget.isProcessing) ...[
                Positioned(
                  left: 12,
                  bottom: 12,
                  child: _buildLabel('Before'),
                ),
                Positioned(
                  right: 12,
                  bottom: 12,
                  child: _buildLabel('After'),
                ),
              ],

              // Original Label (when no enhancement yet)
              if (widget.afterImagePath == null && !widget.isProcessing)
                Positioned(
                  left: 12,
                  bottom: 12,
                  child: _buildLabel('Original'),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLabel(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
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
}

class _ImageClipper extends CustomClipper<Rect> {
  final double clipWidth;

  _ImageClipper(this.clipWidth);

  @override
  Rect getClip(Size size) {
    return Rect.fromLTWH(0, 0, clipWidth, size.height);
  }

  @override
  bool shouldReclip(_ImageClipper oldClipper) {
    return clipWidth != oldClipper.clipWidth;
  }
}

