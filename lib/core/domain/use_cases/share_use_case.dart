import 'dart:async';
import '../repositories/post_repository.dart';


class ShareUseCase {
  final PostRepository _repository;

  ShareUseCase({
    required PostRepository repository,
  })
      : _repository = repository;


  Future<void> addShare({
    required String postId,
    required String userId,
  }) {
    return _repository.addShare(postId: postId, userId: userId);
  }
  Future<void> removeShare({
    required String postId,
    required String userId,
  }) {
    return _repository.removeShare(postId: postId, userId: userId);
  }
}