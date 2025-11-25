import 'package:equatable/equatable.dart';

abstract class HomeEvent extends Equatable {
  const HomeEvent();

  @override
  List<Object?> get props => [];
}

class HomeLoadRequested extends HomeEvent {
  const HomeLoadRequested();
}

class HomeRefreshRequested extends HomeEvent {
  const HomeRefreshRequested();
}

class HomePhotosFetchRequested extends HomeEvent {
  final int page;
  final int limit;

  const HomePhotosFetchRequested({
    this.page = 1,
    this.limit = 20,
  });

  @override
  List<Object?> get props => [page, limit];
}

class HomeNavigationChanged extends HomeEvent {
  final int index;

  const HomeNavigationChanged(this.index);

  @override
  List<Object?> get props => [index];
}


