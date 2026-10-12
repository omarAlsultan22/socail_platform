import 'dart:async';
import '../repositories/post_repository.dart';
import 'package:social_app/core/data/models/post_model.dart';
import 'package:social_app/core/services/session_service.dart';


class PostUseCase {
  final PostRepository _repository;
  final SessionService _sessionService;

  PostUseCase({
    required PostRepository repository,
    required SessionService sessionService,
  })
      : _repository = repository,
        _sessionService = sessionService;

  Future<void> executeInsertPost(PostModel postModel) async {
    await _repository.upsertPostToFirestore(postModel);
  }

  Future<void> executeRemovePost({
    required PostModel postModel
  }) async {
    final isMyPost = postModel.myId == _sessionService.currentUid;

    if (!isMyPost) {
      await _repository.upsertToDeletedPosts(
          postModel.myDocId,
          _sessionService.currentUid
      );
    } else {
      await _repository.deletePostFromFirestore(postModel.myDocId!);
    }
  }
}