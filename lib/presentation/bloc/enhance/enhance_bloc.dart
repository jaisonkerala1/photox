import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image/image.dart' as img;

import '../../../data/services/enhance_service.dart';
import 'enhance_event.dart';
import 'enhance_state.dart';

class EnhanceBloc extends Bloc<EnhanceEvent, EnhanceState> {
  EnhanceBloc() : super(const EnhanceState()) {
    on<EnhanceImageLoaded>(_onImageLoaded);
    on<EnhanceRequested>(_onEnhanceRequested);
    on<EnhanceTypeChanged>(_onTypeChanged);
    on<EnhanceIntensityChanged>(_onIntensityChanged);
    on<EnhanceReset>(_onReset);
    on<EnhanceSaveRequested>(_onSaveRequested);
    on<EnhanceComparisonChanged>(_onComparisonChanged);
    on<_EnhanceProgressUpdate>(_onProgressUpdate);
  }

  void _onProgressUpdate(
    _EnhanceProgressUpdate event,
    Emitter<EnhanceState> emit,
  ) {
    if (state.status == EnhanceStatus.processing) {
      emit(state.copyWith(progress: event.progress));
    }
  }

  Future<void> _onImageLoaded(
    EnhanceImageLoaded event,
    Emitter<EnhanceState> emit,
  ) async {
    emit(state.copyWith(
      status: EnhanceStatus.loading,
      originalImagePath: event.imagePath,
      enhancedImagePath: null,
      isEnhanced: false,
    ));

    // Small delay for smooth transition
    await Future.delayed(const Duration(milliseconds: 300));

    emit(state.copyWith(
      status: EnhanceStatus.initial,
    ));
  }

  Future<void> _onEnhanceRequested(
    EnhanceRequested event,
    Emitter<EnhanceState> emit,
  ) async {
    if (state.originalImagePath == null) return;

    emit(state.copyWith(
      status: EnhanceStatus.processing,
      progress: 0.0,
      errorMessage: null,
    ));

    try {
      // Start progress animation
      Timer? progressTimer;
      double currentProgress = 0.0;
      
      progressTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
        if (currentProgress < 0.9) {
          currentProgress += 0.02;
          add(_EnhanceProgressUpdate(currentProgress));
        }
      });

      // Convert enhance type to string for API
      final enhanceTypeStr = _enhanceTypeToString(state.enhanceType);

      // Call the real API
      final result = await EnhanceService.enhanceImage(
        imagePath: state.originalImagePath!,
        enhanceType: enhanceTypeStr,
      );

      // Stop progress timer
      progressTimer.cancel();

      if (result.success && result.enhancedImagePath != null) {
        emit(state.copyWith(
          status: EnhanceStatus.success,
          enhancedImagePath: result.enhancedImagePath,
          isEnhanced: true,
          progress: 1.0,
        ));
      } else {
        emit(state.copyWith(
          status: EnhanceStatus.error,
          errorMessage: result.error ?? 'Enhancement failed. Please try again.',
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        status: EnhanceStatus.error,
        errorMessage: 'Enhancement failed: ${e.toString()}',
      ));
    }
  }

  String _enhanceTypeToString(EnhanceType type) {
    switch (type) {
      case EnhanceType.auto:
        return 'auto';
      case EnhanceType.portrait:
        return 'portrait';
      case EnhanceType.landscape:
        return 'landscape';
      case EnhanceType.lowLight:
        return 'lowLight';
      case EnhanceType.hdr:
        return 'hdr';
    }
  }

  void _onTypeChanged(
    EnhanceTypeChanged event,
    Emitter<EnhanceState> emit,
  ) {
    emit(state.copyWith(
      enhanceType: event.type,
      // Reset enhanced state when type changes
      isEnhanced: false,
      enhancedImagePath: null,
    ));
  }

  void _onIntensityChanged(
    EnhanceIntensityChanged event,
    Emitter<EnhanceState> emit,
  ) {
    emit(state.copyWith(
      intensity: event.intensity,
    ));
  }

  void _onReset(
    EnhanceReset event,
    Emitter<EnhanceState> emit,
  ) {
    emit(state.copyWith(
      status: EnhanceStatus.initial,
      enhancedImagePath: null,
      isEnhanced: false,
      progress: 0.0,
      comparisonPosition: 0.5,
      intensity: 0.8,
      enhanceType: EnhanceType.auto,
    ));
  }

  Future<void> _onSaveRequested(
    EnhanceSaveRequested event,
    Emitter<EnhanceState> emit,
  ) async {
    if (state.enhancedImagePath == null) return;

    emit(state.copyWith(status: EnhanceStatus.loading));

    try {
      // Get the downloads/pictures directory
      final directory = await getApplicationDocumentsDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final savePath = '${directory.path}/enhanced_$timestamp.png';

      // Read the enhanced image
      final originalFile = File(state.enhancedImagePath!);
      final bytes = await originalFile.readAsBytes();
      
      // Apply brightness adjustment if needed
      if (event.brightness != 0.0) {
        // Decode image
        final image = img.decodeImage(bytes);
        if (image != null) {
          // Apply brightness adjustment
          // brightness: -0.5 to 0.5 maps to -128 to 128
          final brightnessValue = (event.brightness * 256).toInt();
          final adjustedImage = img.adjustColor(image, brightness: brightnessValue);
          
          // Encode and save
          final adjustedBytes = img.encodePng(adjustedImage);
          await File(savePath).writeAsBytes(adjustedBytes);
        } else {
          // Fallback: just copy the file
          await originalFile.copy(savePath);
        }
      } else {
        // No brightness adjustment, just copy
        await originalFile.copy(savePath);
      }

      emit(state.copyWith(
        status: EnhanceStatus.saved,
      ));

      // Reset to success state after showing saved message
      await Future.delayed(const Duration(seconds: 2));
      emit(state.copyWith(status: EnhanceStatus.success));
    } catch (e) {
      emit(state.copyWith(
        status: EnhanceStatus.error,
        errorMessage: 'Failed to save image: ${e.toString()}',
      ));
    }
  }

  void _onComparisonChanged(
    EnhanceComparisonChanged event,
    Emitter<EnhanceState> emit,
  ) {
    emit(state.copyWith(comparisonPosition: event.position));
  }
}

// Internal event for progress updates
class _EnhanceProgressUpdate extends EnhanceEvent {
  final double progress;
  const _EnhanceProgressUpdate(this.progress);
  
  @override
  List<Object?> get props => [progress];
}
