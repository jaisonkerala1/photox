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

class AgingScreen extends StatefulWidget {
  final String imagePath;

  const AgingScreen({
    super.key,
    required this.imagePath,
  });

  @override
  State<AgingScreen> createState() => _AgingScreenState();
}

class _AgingScreenState extends State<AgingScreen> {
  late PhotoEditorBloc _bloc;
  int _selectedAge = 60;
  final List<int> _ageOptions = [20, 30, 40, 50, 60, 70, 80, 90];

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

  void _onApplyAging() {
    _bloc.add(PhotoEditorAgingRequested(
      image: File(widget.imagePath),
      targetAge: _selectedAge,
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
                'editType': 'Aged to $_selectedAge',
              },
            );
          } else if (state.hasError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage ?? 'Aging effect failed'),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
        builder: (context, state) {
          return Scaffold(
            backgroundColor: AppColors.background,
            appBar: AppBar(
              title: const Text('AI Aging'),
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
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Select Target Age',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'See what you\'ll look like at different ages',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                          
                          const SizedBox(height: 16),
                          
                          // Age selector
                          SizedBox(
                            height: 60,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: _ageOptions.length,
                              itemBuilder: (context, index) {
                                final age = _ageOptions[index];
                                final isSelected = age == _selectedAge;
                                return GestureDetector(
                                  onTap: () {
                                    setState(() => _selectedAge = age);
                                  },
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    width: 60,
                                    margin: const EdgeInsets.only(right: 12),
                                    decoration: BoxDecoration(
                                      gradient: isSelected
                                          ? const LinearGradient(colors: AppColors.proGradient)
                                          : null,
                                      color: isSelected ? null : AppColors.surfaceVariant,
                                      borderRadius: BorderRadius.circular(16),
                                      border: isSelected
                                          ? null
                                          : Border.all(color: AppColors.cardBorder),
                                    ),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          '$age',
                                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                            fontWeight: FontWeight.bold,
                                            color: isSelected ? Colors.white : AppColors.textPrimary,
                                          ),
                                        ),
                                        Text(
                                          'yrs',
                                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                            color: isSelected ? Colors.white70 : AppColors.textSecondary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          
                          const SizedBox(height: 24),
                          
                          // Apply button
                          CustomButton(
                            text: 'See Your Future',
                            onPressed: state.isProcessing ? null : _onApplyAging,
                            isLoading: state.isProcessing,
                            isFullWidth: true,
                            gradientColors: AppColors.proGradient,
                            prefixIcon: Icons.elderly_rounded,
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
                        title: 'Aging Your Photo',
                        subtitle: 'Traveling through time...',
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

