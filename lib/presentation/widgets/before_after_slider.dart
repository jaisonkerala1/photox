import 'dart:io';

import 'package:flutter/material.dart';

import '../../config/theme/app_colors.dart';

class BeforeAfterSlider extends StatefulWidget {
  final String beforeImage;
  final String afterImage;
  final double initialPosition;

  const BeforeAfterSlider({
    super.key,
    required this.beforeImage,
    required this.afterImage,
    this.initialPosition = 0.5,
  });

  @override
  State<BeforeAfterSlider> createState() => _BeforeAfterSliderState();
}

class _BeforeAfterSliderState extends State<BeforeAfterSlider> {
  late double _sliderPosition;

  @override
  void initState() {
    super.initState();
    _sliderPosition = widget.initialPosition;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return GestureDetector(
          onHorizontalDragUpdate: (details) {
            setState(() {
              _sliderPosition = (details.localPosition.dx / constraints.maxWidth)
                  .clamp(0.0, 1.0);
            });
          },
          child: Stack(
            children: [
              // After image (full width)
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: _buildImage(widget.afterImage),
              ),
              
              // Before image (clipped)
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: ClipRect(
                  clipper: _SliderClipper(_sliderPosition),
                  child: _buildImage(widget.beforeImage),
                ),
              ),
              
              // Slider line
              Positioned(
                left: constraints.maxWidth * _sliderPosition - 2,
                top: 0,
                bottom: 0,
                child: Container(
                  width: 4,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 8,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                ),
              ),
              
              // Slider handle
              Positioned(
                left: constraints.maxWidth * _sliderPosition - 24,
                top: constraints.maxHeight / 2 - 24,
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 12,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.chevron_left_rounded,
                        size: 20,
                        color: AppColors.textTertiary,
                      ),
                      Icon(
                        Icons.chevron_right_rounded,
                        size: 20,
                        color: AppColors.textTertiary,
                      ),
                    ],
                  ),
                ),
              ),
              
              // Labels
              Positioned(
                top: 16,
                left: 16,
                child: _buildLabel('Before'),
              ),
              Positioned(
                top: 16,
                right: 16,
                child: _buildLabel('After'),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildImage(String path) {
    if (path.startsWith('http')) {
      return Image.network(
        path,
        fit: BoxFit.contain,
        width: double.infinity,
        height: double.infinity,
      );
    }
    return Image.file(
      File(path),
      fit: BoxFit.contain,
      width: double.infinity,
      height: double.infinity,
    );
  }

  Widget _buildLabel(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _SliderClipper extends CustomClipper<Rect> {
  final double position;

  _SliderClipper(this.position);

  @override
  Rect getClip(Size size) {
    return Rect.fromLTWH(0, 0, size.width * position, size.height);
  }

  @override
  bool shouldReclip(covariant _SliderClipper oldClipper) {
    return position != oldClipper.position;
  }
}


