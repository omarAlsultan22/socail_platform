import '../repository/likes_repository.dart';
import 'package:social_app/core/data/models/my_model.dart';


class GetLikesStreamUseCase {
  final LikesRepository _repository;

  GetLikesStreamUseCase({required LikesRepository repository})
      : _repository = repository;

  Stream<List<MyModel>> call(String postId) {
    return _repository.getLikesStream(postId);
  }
}