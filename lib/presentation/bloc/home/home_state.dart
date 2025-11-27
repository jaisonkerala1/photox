import 'package:equatable/equatable.dart';

import '../../../domain/entities/photo.dart';

enum HomeStatus {
  initial,
  loading,
  loaded,
  error,
}

class HomeState extends Equatable {
  final HomeStatus status;
  final List<Photo> photos;
  final int currentNavigationIndex;
  final String? errorMessage;
  final bool hasReachedMax;
  final int currentPage;

  const HomeState({
    this.status = HomeStatus.initial,
    this.photos = const [],
    this.currentNavigationIndex = 0,
    this.errorMessage,
    this.hasReachedMax = false,
    this.currentPage = 1,
  });

  const HomeState.initial() : this();

  HomeState copyWith({
    HomeStatus? status,
    List<Photo>? photos,
    int? currentNavigationIndex,
    String? errorMessage,
    bool? hasReachedMax,
    int? currentPage,
  }) {
    return HomeState(
      status: status ?? this.status,
      photos: photos ?? this.photos,
      currentNavigationIndex: currentNavigationIndex ?? this.currentNavigationIndex,
      errorMessage: errorMessage ?? this.errorMessage,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      currentPage: currentPage ?? this.currentPage,
    );
  }

  bool get isLoading => status == HomeStatus.loading;
  bool get isLoaded => status == HomeStatus.loaded;
  bool get hasError => status == HomeStatus.error;

  @override
  List<Object?> get props => [
    status,
    photos,
    currentNavigationIndex,
    errorMessage,
    hasReachedMax,
    currentPage,
  ];
}





