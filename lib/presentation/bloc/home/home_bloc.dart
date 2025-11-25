import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/usecases/photo/get_photos_usecase.dart';
import 'home_event.dart';
import 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final GetPhotosUseCase getPhotosUseCase;

  HomeBloc({
    required this.getPhotosUseCase,
  }) : super(const HomeState.initial()) {
    on<HomeLoadRequested>(_onLoadRequested);
    on<HomeRefreshRequested>(_onRefreshRequested);
    on<HomePhotosFetchRequested>(_onPhotosFetchRequested);
    on<HomeNavigationChanged>(_onNavigationChanged);
  }

  Future<void> _onLoadRequested(
    HomeLoadRequested event,
    Emitter<HomeState> emit,
  ) async {
    emit(state.copyWith(status: HomeStatus.loading));
    
    try {
      final photos = await getPhotosUseCase(page: 1, limit: 20);
      emit(state.copyWith(
        status: HomeStatus.loaded,
        photos: photos,
        currentPage: 1,
        hasReachedMax: photos.length < 20,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: HomeStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onRefreshRequested(
    HomeRefreshRequested event,
    Emitter<HomeState> emit,
  ) async {
    try {
      final photos = await getPhotosUseCase(page: 1, limit: 20);
      emit(state.copyWith(
        status: HomeStatus.loaded,
        photos: photos,
        currentPage: 1,
        hasReachedMax: photos.length < 20,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: HomeStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onPhotosFetchRequested(
    HomePhotosFetchRequested event,
    Emitter<HomeState> emit,
  ) async {
    if (state.hasReachedMax) return;

    try {
      final photos = await getPhotosUseCase(
        page: event.page,
        limit: event.limit,
      );
      emit(state.copyWith(
        status: HomeStatus.loaded,
        photos: [...state.photos, ...photos],
        currentPage: event.page,
        hasReachedMax: photos.length < event.limit,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: HomeStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  void _onNavigationChanged(
    HomeNavigationChanged event,
    Emitter<HomeState> emit,
  ) {
    emit(state.copyWith(currentNavigationIndex: event.index));
  }
}


