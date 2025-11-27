import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/photo.dart';
import '../../../domain/usecases/ai/aging_effect_usecase.dart';
import '../../../domain/usecases/ai/apply_filter_usecase.dart';
import '../../../domain/usecases/ai/enhance_photo_usecase.dart';
import '../../../domain/usecases/ai/face_swap_usecase.dart';
import '../../../domain/usecases/ai/restore_photo_usecase.dart';
import '../../../domain/usecases/ai/style_transfer_usecase.dart';
import 'photo_editor_event.dart';
import 'photo_editor_state.dart';

class PhotoEditorBloc extends Bloc<PhotoEditorEvent, PhotoEditorState> {
  final EnhancePhotoUseCase enhancePhotoUseCase;
  final RestorePhotoUseCase restorePhotoUseCase;
  final FaceSwapUseCase faceSwapUseCase;
  final AgingEffectUseCase agingEffectUseCase;
  final StyleTransferUseCase styleTransferUseCase;
  final ApplyFilterUseCase applyFilterUseCase;

  PhotoEditorBloc({
    required this.enhancePhotoUseCase,
    required this.restorePhotoUseCase,
    required this.faceSwapUseCase,
    required this.agingEffectUseCase,
    required this.styleTransferUseCase,
    required this.applyFilterUseCase,
  }) : super(const PhotoEditorState.initial()) {
    on<PhotoEditorImageSelected>(_onImageSelected);
    on<PhotoEditorEnhanceRequested>(_onEnhanceRequested);
    on<PhotoEditorRestoreRequested>(_onRestoreRequested);
    on<PhotoEditorFaceSwapRequested>(_onFaceSwapRequested);
    on<PhotoEditorAgingRequested>(_onAgingRequested);
    on<PhotoEditorStyleTransferRequested>(_onStyleTransferRequested);
    on<PhotoEditorFilterRequested>(_onFilterRequested);
    on<PhotoEditorReset>(_onReset);
    on<PhotoEditorSaveRequested>(_onSaveRequested);
  }

  void _onImageSelected(
    PhotoEditorImageSelected event,
    Emitter<PhotoEditorState> emit,
  ) {
    emit(state.copyWith(
      status: PhotoEditorStatus.imageSelected,
      selectedImage: event.image,
    ));
  }

  Future<void> _onEnhanceRequested(
    PhotoEditorEnhanceRequested event,
    Emitter<PhotoEditorState> emit,
  ) async {
    emit(state.copyWith(
      status: PhotoEditorStatus.processing,
      currentEditType: EditType.enhance,
      processingMessage: 'Enhancing your photo...',
    ));

    try {
      final result = await enhancePhotoUseCase(
        event.image,
        intensity: event.intensity,
      );
      emit(state.copyWith(
        status: PhotoEditorStatus.completed,
        result: result,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: PhotoEditorStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onRestoreRequested(
    PhotoEditorRestoreRequested event,
    Emitter<PhotoEditorState> emit,
  ) async {
    emit(state.copyWith(
      status: PhotoEditorStatus.processing,
      currentEditType: EditType.restore,
      processingMessage: 'Restoring your photo...',
    ));

    try {
      final result = await restorePhotoUseCase(
        event.image,
        colorize: event.colorize,
        removeDamage: event.removeDamage,
      );
      emit(state.copyWith(
        status: PhotoEditorStatus.completed,
        result: result,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: PhotoEditorStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onFaceSwapRequested(
    PhotoEditorFaceSwapRequested event,
    Emitter<PhotoEditorState> emit,
  ) async {
    emit(state.copyWith(
      status: PhotoEditorStatus.processing,
      currentEditType: EditType.faceSwap,
      processingMessage: 'Swapping faces...',
    ));

    try {
      final result = await faceSwapUseCase(
        event.sourceImage,
        event.targetImage,
      );
      emit(state.copyWith(
        status: PhotoEditorStatus.completed,
        result: result,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: PhotoEditorStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onAgingRequested(
    PhotoEditorAgingRequested event,
    Emitter<PhotoEditorState> emit,
  ) async {
    emit(state.copyWith(
      status: PhotoEditorStatus.processing,
      currentEditType: EditType.aging,
      processingMessage: 'Applying aging effect...',
    ));

    try {
      final result = await agingEffectUseCase(
        event.image,
        event.targetAge,
      );
      emit(state.copyWith(
        status: PhotoEditorStatus.completed,
        result: result,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: PhotoEditorStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onStyleTransferRequested(
    PhotoEditorStyleTransferRequested event,
    Emitter<PhotoEditorState> emit,
  ) async {
    emit(state.copyWith(
      status: PhotoEditorStatus.processing,
      currentEditType: EditType.styleTransfer,
      processingMessage: 'Applying style...',
    ));

    try {
      final result = await styleTransferUseCase(
        event.image,
        event.style,
      );
      emit(state.copyWith(
        status: PhotoEditorStatus.completed,
        result: result,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: PhotoEditorStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onFilterRequested(
    PhotoEditorFilterRequested event,
    Emitter<PhotoEditorState> emit,
  ) async {
    emit(state.copyWith(
      status: PhotoEditorStatus.processing,
      currentEditType: EditType.filter,
      processingMessage: 'Applying filter...',
    ));

    try {
      final result = await applyFilterUseCase(
        event.image,
        event.filterName,
      );
      emit(state.copyWith(
        status: PhotoEditorStatus.completed,
        result: result,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: PhotoEditorStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  void _onReset(
    PhotoEditorReset event,
    Emitter<PhotoEditorState> emit,
  ) {
    emit(const PhotoEditorState.initial());
  }

  Future<void> _onSaveRequested(
    PhotoEditorSaveRequested event,
    Emitter<PhotoEditorState> emit,
  ) async {
    // TODO: Implement save to gallery logic
    emit(state.copyWith(status: PhotoEditorStatus.saved));
  }
}





