import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../config/routes/app_routes.dart';
import '../../../config/theme/app_colors.dart';
import '../../../core/di/injection.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/loading_indicator.dart';
import '../../bloc/photo_editor/photo_editor_bloc.dart';
import '../../bloc/photo_editor/photo_editor_event.dart';
import '../../bloc/photo_editor/photo_editor_state.dart';

class EnhanceScreen extends StatefulWidget {
  final String imagePath;

  const EnhanceScreen({
    super.key,
    required this.imagePath,
  });

  @override
  State<EnhanceScreen> createState() => _EnhanceScreenState();
}

class _EnhanceScreenState extends State<EnhanceScreen> {
  late PhotoEditorBloc _bloc;
  double _intensity = 50;

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

  void _onEnhance() {
    _bloc.add(PhotoEditorEnhanceRequested(
      image: File(widget.imagePath),
      intensity: _intensity.toInt(),
    ));
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
                'originalImagePath': widget.imagePath,
                'resultImagePath': state.result!.resultImagePath,
                'editType': 'Enhanced',
              },
            );
          } else if (state.hasError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage ?? 'Enhancement failed'),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
        builder: (context, state) {
          return Scaffold(
            backgroundColor: AppColors.background,
            appBar: AppBar(
              title: const Text('Enhance Photo'),
              leading: IconButton(
                icon: const Icon(Icons.close_rounded),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
            body: Stack(
              children: [
                Column(
                  children: [
                    // Image preview
                    Expanded(
                      child: Container(
                        margin: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Image.file(
                            File(widget.imagePath),
                            fit: BoxFit.contain,
                          ),
                        ),
                      ).animate().fadeIn().scale(begin: const Offset(0.95, 0.95)),
                    ),
                    
                    // Controls
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
                          // Intensity slider
                          Row(
                            children: [
                              const Icon(
                                Icons.auto_awesome_rounded,
                                color: AppColors.primary,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Enhancement Intensity',
                                          style: Theme.of(context).textTheme.titleSmall,
                                        ),
                                        Text(
                                          '${_intensity.toInt()}%',
                                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                            color: AppColors.primary,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    SliderTheme(
                                      data: SliderThemeData(
                                        activeTrackColor: AppColors.primary,
                                        inactiveTrackColor: AppColors.surfaceVariant,
                                        thumbColor: AppColors.primary,
                                        overlayColor: AppColors.primary.withOpacity(0.2),
                                        trackHeight: 6,
                                        thumbShape: const RoundSliderThumbShape(
                                          enabledThumbRadius: 10,
                                        ),
                                      ),
                                      child: Slider(
                                        value: _intensity,
                                        min: 0,
                                        max: 100,
                                        onChanged: (value) {
                                          setState(() {
                                            _intensity = value;
                                          });
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          
                          const SizedBox(height: 24),
                          
                          // Enhance button
                          CustomButton(
                            text: 'Enhance Now',
                            onPressed: state.isProcessing ? null : _onEnhance,
                            isLoading: state.isProcessing,
                            isFullWidth: true,
                            prefixIcon: Icons.auto_awesome_rounded,
                          ),
                          
                          const SizedBox(height: 8),
                        ],
                      ),
                    ),
                  ],
                ),
                
                // Processing overlay
                if (state.isProcessing)
                  Container(
                    color: AppColors.overlayDark,
                    child: Center(
                      child: ProcessingIndicator(
                        title: 'Enhancing Your Photo',
                        subtitle: 'AI is working its magic...',
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

