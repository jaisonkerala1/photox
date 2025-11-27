import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../config/routes/app_routes.dart';
import '../../../config/theme/app_colors.dart';
import '../../../core/widgets/custom_button.dart';
import '../../widgets/before_after_slider.dart';

class ResultScreen extends StatefulWidget {
  final String originalImagePath;
  final String resultImagePath;
  final String editType;

  const ResultScreen({
    super.key,
    required this.originalImagePath,
    required this.resultImagePath,
    required this.editType,
  });

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  bool _showComparison = true;

  void _onShare() async {
    // Stub - share functionality not implemented
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Share functionality not implemented yet'),
        backgroundColor: AppColors.info,
      ),
    );
  }

  void _onSave() async {
    // TODO: Implement save to gallery
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Photo saved to gallery!'),
        backgroundColor: AppColors.success,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceVariant,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.close_rounded),
                    ),
                  ),
                  Column(
                    children: [
                      Text(
                        widget.editType,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.success.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Completed',
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: AppColors.success,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    onPressed: () {
                      setState(() => _showComparison = !_showComparison);
                    },
                    icon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: _showComparison
                            ? AppColors.primary.withOpacity(0.2)
                            : AppColors.surfaceVariant,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.compare_rounded,
                        color: _showComparison ? AppColors.primary : null,
                      ),
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn().slideY(begin: -0.1),
            
            // Image view
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _showComparison
                    ? BeforeAfterSlider(
                        beforeImage: widget.originalImagePath,
                        afterImage: widget.resultImagePath,
                      ).animate().fadeIn(delay: 200.ms)
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Image.file(
                          File(widget.resultImagePath),
                          fit: BoxFit.contain,
                        ),
                      ).animate().fadeIn(delay: 200.ms),
              ),
            ),
            
            // Actions
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(32),
                ),
              ),
              child: Column(
                children: [
                  // Quick actions
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _ActionButton(
                        icon: Icons.refresh_rounded,
                        label: 'Edit Again',
                        onTap: () => Navigator.of(context).pop(),
                      ),
                      _ActionButton(
                        icon: Icons.compare_rounded,
                        label: 'Compare',
                        onTap: () {
                          setState(() => _showComparison = !_showComparison);
                        },
                        isActive: _showComparison,
                      ),
                      _ActionButton(
                        icon: Icons.share_rounded,
                        label: 'Share',
                        onTap: _onShare,
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Main actions
                  Row(
                    children: [
                      Expanded(
                        child: CustomButton(
                          text: 'Save',
                          onPressed: _onSave,
                          type: ButtonType.secondary,
                          prefixIcon: Icons.download_rounded,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: CustomButton(
                          text: 'New Edit',
                          onPressed: () {
                            Navigator.of(context).pushNamedAndRemoveUntil(
                              AppRoutes.home,
                              (route) => false,
                            );
                          },
                          prefixIcon: Icons.add_photo_alternate_rounded,
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 8),
                ],
              ),
            ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.1),
          ],
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isActive;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isActive
                  ? AppColors.primary.withOpacity(0.2)
                  : AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              icon,
              color: isActive ? AppColors.primary : AppColors.textSecondary,
              size: 24,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: isActive ? AppColors.primary : AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}





