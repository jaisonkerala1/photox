import '../../entities/photo.dart';
import '../../repositories/photo_repository.dart';

class GetPhotosUseCase {
  final PhotoRepository _repository;

  GetPhotosUseCase(this._repository);

  Future<List<Photo>> call({
    int page = 1,
    int limit = 20,
    EditType? editType,
  }) {
    return _repository.getPhotos(
      page: page,
      limit: limit,
      editType: editType,
    );
  }
}





