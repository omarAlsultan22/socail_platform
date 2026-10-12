import 'dart:async';
import '../repositories/post_repository.dart';
import 'package:social_app/core/data/models/post_model.dart';


class LikeUseCase {
  final PostRepository _repository;

  LikeUseCase({
    required PostRepository repository,
  })
      : _repository = repository;


  Future<void> toggleLike({
    required bool isActive,
    required PostModel postModel,
  }) {
    if (isActive) {
      return _repository.addLike(
          postId: postModel.myDocId, userId: postModel.myId);
    }
    return _repository.removeLike(
        postId: postModel.myDocId, userId: postModel.myId);
  }
}