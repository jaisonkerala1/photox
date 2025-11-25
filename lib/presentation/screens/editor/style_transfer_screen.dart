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

class StyleTransferScreen extends StatefulWidget {
  final String imagePath;

  const StyleTransferScreen({
    super.key,
    required this.imagePath,
  });

  @override
  State<StyleTransferScreen> createState() => _StyleTransferScreenState();
}

class _StyleTransferScreenState extends State<StyleTransferScreen> {
  late PhotoEditorBloc _bloc;
  String _selectedStyle = 'anime';

  final List<_StyleOption> _styles = [
    _StyleOption('anime', 'Anime', [Color(0xFFFF6B6B), Color(0xFFFF8E53)]),
    _StyleOption('oil_painting', 'Oil Paint', [Color(0xFF667EEA), Color(0xFF764BA2)]),
    _StyleOption('watercolor', 'Watercolor', [Color(0xFF4FC3F7), Color(0xFF00B0FF)]),
    _StyleOption('sketch', 'Sketch', [Color(0xFF2C3E50), Color(0xFF4CA1AF)]),
    _StyleOption('pop_art', 'Pop Art', [Color(0xFFFFD93D), Color(0xFFFF8C00)]),
    _StyleOption('cyberpunk', 'Cyberpunk', [Color(0xFF00F5D4), Color(0xFF00BBF9)]),
    _StyleOption('vintage', 'Vintage', [Color(0xFFFF9A9E), Color(0xFFFAD0C4)]),
    _StyleOption('comic', 'Comic', [Color(0xFF11998E), Color(0xFF38EF7D)]),
  ];

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

  void _onApplyStyle() {
    _bloc.add(PhotoEditorStyleTransferRequested(
      image: File(widget.imagePath),
      style: _selectedStyle,
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
                'editType': 'Style Transfer',
              },
            );
          } else if (state.hasError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage ?? 'Style transfer failed'),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
        builder: (context, state) {
          return Scaffold(
            backgroundColor: AppColors.background,
            appBar: AppBar(
              title: const Text('Art Styles'),
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
                      flex: 2,
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
                    
                    // Style selector
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
                            'Choose Your Style',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          
                          const SizedBox(height: 16),
                          
                          // Styles grid
                          SizedBox(
                            height: 100,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: _styles.length,
                              itemBuilder: (context, index) {
                                final style = _styles[index];
                                final isSelected = style.id == _selectedStyle;
                                return GestureDetector(
                                  onTap: () {
                                    setState(() => _selectedStyle = style.id);
                                  },
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    width: 80,
                                    margin: const EdgeInsets.only(right: 12),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: style.gradient,
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                      borderRadius: BorderRadius.circular(16),
                                      border: isSelected
                                          ? Border.all(color: Colors.white, width: 3)
                                          : null,
                                      boxShadow: isSelected
                                          ? [
                                              BoxShadow(
                                                color: style.gradient.first.withOpacity(0.5),
                                                blurRadius: 12,
                                                offset: const Offset(0, 4),
                                              ),
                                            ]
                                          : null,
                                    ),
                                    child: Stack(
                                      children: [
                                        Center(
                                          child: Text(
                                            style.name,
                                            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                        if (isSelected)
                                          Positioned(
                                            top: 4,
                                            right: 4,
                                            child: Container(
                                              padding: const EdgeInsets.all(2),
                                              decoration: const BoxDecoration(
                                                color: Colors.white,
                                                shape: BoxShape.circle,
                                              ),
                                              child: Icon(
                                                Icons.check_rounded,
                                                size: 14,
                                                color: style.gradient.first,
                                              ),
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
                            text: 'Apply Style',
                            onPressed: state.isProcessing ? null : _onApplyStyle,
                            isLoading: state.isProcessing,
                            isFullWidth: true,
                            prefixIcon: Icons.palette_rounded,
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
                        title: 'Applying Style',
                        subtitle: 'Creating your masterpiece...',
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

class _StyleOption {
  final String id;
  final String name;
  final List<Color> gradient;

  _StyleOption(this.id, this.name, this.gradient);
}

