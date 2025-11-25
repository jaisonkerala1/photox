import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../config/routes/app_routes.dart';
import '../../../config/theme/app_colors.dart';
import '../../../core/di/injection.dart';
import '../../../core/utils/image_picker_util.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/loading_indicator.dart';
import '../../bloc/photo_editor/photo_editor_bloc.dart';
import '../../bloc/photo_editor/photo_editor_event.dart';
import '../../bloc/photo_editor/photo_editor_state.dart';

class FaceSwapScreen extends StatefulWidget {
  const FaceSwapScreen({super.key});

  @override
  State<FaceSwapScreen> createState() => _FaceSwapScreenState();
}

class _FaceSwapScreenState extends State<FaceSwapScreen> {
  late PhotoEditorBloc _bloc;
  File? _sourceImage;
  File? _targetImage;

  @override
  void initState() {
    super.initState();
    _bloc = getIt<PhotoEditorBloc>();
  }

  @override
  void dispose() {
    _bloc.close();
    super.dispose();
  }

  void _pickSourceImage() {
    ImagePickerUtil.showImageSourceDialog(
      context,
      onImageSelected: (file) {
        setState(() => _sourceImage = file);
      },
    );
  }

  void _pickTargetImage() {
    ImagePickerUtil.showImageSourceDialog(
      context,
      onImageSelected: (file) {
        setState(() => _targetImage = file);
      },
    );
  }

  void _onSwap() {
    if (_sourceImage != null && _targetImage != null) {
      _bloc.add(PhotoEditorFaceSwapRequested(
        sourceImage: _sourceImage!,
        targetImage: _targetImage!,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _bloc,
      child: BlocConsumer<PhotoEditorBloc, PhotoEditorState>(
        listener: (context, state) {
          if (state.status == PhotoEditorStatus.completed && state.result != null) {
            Navigator.of(context).pushReplacementNamed(
              AppRoutes.result,
              arguments: {
                'originalImagePath': _sourceImage!.path,
                'resultImagePath': state.result!.resultImagePath,
                'editType': 'Face Swapped',
              },
            );
          } else if (state.hasError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage ?? 'Face swap failed'),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
        builder: (context, state) {
          return Scaffold(
            backgroundColor: AppColors.background,
            appBar: AppBar(
              title: const Text('Face Swap'),
              leading: IconButton(
                icon: const Icon(Icons.close_rounded),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
            body: Stack(
              children: [
                SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Select two photos to swap faces',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Source image
                      _ImageSelector(
                        label: 'Your Face',
                        description: 'The face you want to use',
                        image: _sourceImage,
                        onTap: _pickSourceImage,
                        gradient: AppColors.primaryGradient,
                      ).animate().fadeIn().slideX(begin: -0.1),
                      
                      const SizedBox(height: 16),
                      
                      // Swap indicator
                      Center(
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceVariant,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.swap_vert_rounded,
                            color: AppColors.primary,
                            size: 32,
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Target image
                      _ImageSelector(
                        label: 'Target Photo',
                        description: 'The photo where face will be placed',
                        image: _targetImage,
                        onTap: _pickTargetImage,
                        gradient: AppColors.purpleGradient,
                      ).animate().fadeIn(delay: 100.ms).slideX(begin: -0.1),
                      
                      const SizedBox(height: 32),
                      
                      // Swap button
                      CustomButton(
                        text: 'Swap Faces',
                        onPressed: (_sourceImage != null && _targetImage != null && !state.isProcessing)
                            ? _onSwap
                            : null,
                        isLoading: state.isProcessing,
                        isFullWidth: true,
                        gradientColors: AppColors.purpleGradient,
                        prefixIcon: Icons.face_retouching_natural,
                      ),
                    ],
                  ),
                ),
                
                // Processing overlay
                if (state.isProcessing)
                  Container(
                    color: AppColors.overlayDark,
                    child: Center(
                      child: ProcessingIndicator(
                        title: 'Swapping Faces',
                        subtitle: 'Creating your new look...',
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _ImageSelector extends StatelessWidget {
  final String label;
  final String description;
  final File? image;
  final VoidCallback onTap;
  final List<Color> gradient;

  const _ImageSelector({
    required this.label,
    required this.description,
    required this.image,
    required this.onTap,
    required this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 200,
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: image != null ? gradient.first : AppColors.cardBorder,
            width: image != null ? 2 : 1,
          ),
        ),
        child: image != null
            ? Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(18),
                    child: Image.file(
                      image!,
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.edit_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: gradient),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        label,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                ],
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: gradient.map((c) => c.withOpacity(0.2)).toList(),
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.add_photo_alternate_rounded,
                      size: 40,
                      color: gradient.first,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    label,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

