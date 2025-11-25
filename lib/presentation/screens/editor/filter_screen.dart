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

class FilterScreen extends StatefulWidget {
  final String imagePath;

  const FilterScreen({
    super.key,
    required this.imagePath,
  });

  @override
  State<FilterScreen> createState() => _FilterScreenState();
}

class _FilterScreenState extends State<FilterScreen> {
  late PhotoEditorBloc _bloc;
  String _selectedFilter = 'instant_snap';

  final List<_FilterOption> _filters = [
    _FilterOption('instant_snap', 'Instant Snap', [Color(0xFFFF6B6B), Color(0xFFFF8E53)]),
    _FilterOption('figurine', 'Figurine', [Color(0xFF11998E), Color(0xFF38EF7D)]),
    _FilterOption('ghostface', 'Ghostface', [Color(0xFF2C3E50), Color(0xFF4CA1AF)]),
    _FilterOption('cozy_vibes', 'Cozy Vibes', [Color(0xFFFF9A9E), Color(0xFFFAD0C4)]),
    _FilterOption('green_trouble', 'Green Trouble', [Color(0xFF56AB2F), Color(0xFFA8E6CF)]),
    _FilterOption('snow_globe', 'Snow Globe', [Color(0xFF74EBD5), Color(0xFFACB6E5)]),
    _FilterOption('santa', 'Santa', [Color(0xFFE53935), Color(0xFF43A047)]),
    _FilterOption('neon_glow', 'Neon Glow', [Color(0xFF00F5D4), Color(0xFFFF00FF)]),
    _FilterOption('vintage_film', 'Vintage Film', [Color(0xFFD4A574), Color(0xFF8B7355)]),
    _FilterOption('dreamy', 'Dreamy', [Color(0xFFE8C4F9), Color(0xFFA78BFA)]),
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

  void _onApplyFilter() {
    _bloc.add(PhotoEditorFilterRequested(
      image: File(widget.imagePath),
      filterName: _selectedFilter,
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
                'editType': 'Filtered',
              },
            );
          } else if (state.hasError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage ?? 'Filter failed'),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
        builder: (context, state) {
          return Scaffold(
            backgroundColor: AppColors.background,
            appBar: AppBar(
              title: const Text('Trending Filters'),
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
                    
                    // Filter selector
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
                            'Select Filter',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          
                          const SizedBox(height: 16),
                          
                          // Filters list
                          SizedBox(
                            height: 90,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: _filters.length,
                              itemBuilder: (context, index) {
                                final filter = _filters[index];
                                final isSelected = filter.id == _selectedFilter;
                                return GestureDetector(
                                  onTap: () {
                                    setState(() => _selectedFilter = filter.id);
                                  },
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    width: 80,
                                    margin: const EdgeInsets.only(right: 12),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: filter.gradient,
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                      ),
                                      borderRadius: BorderRadius.circular(16),
                                      border: isSelected
                                          ? Border.all(color: Colors.white, width: 3)
                                          : null,
                                    ),
                                    child: Stack(
                                      children: [
                                        Positioned(
                                          bottom: 8,
                                          left: 4,
                                          right: 4,
                                          child: Text(
                                            filter.name,
                                            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                            ),
                                            textAlign: TextAlign.center,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
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
                                                size: 12,
                                                color: filter.gradient.first,
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
                            text: 'Apply Filter',
                            onPressed: state.isProcessing ? null : _onApplyFilter,
                            isLoading: state.isProcessing,
                            isFullWidth: true,
                            prefixIcon: Icons.filter_vintage_rounded,
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
                        title: 'Applying Filter',
                        subtitle: 'Adding some magic...',
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

class _FilterOption {
  final String id;
  final String name;
  final List<Color> gradient;

  _FilterOption(this.id, this.name, this.gradient);
}

