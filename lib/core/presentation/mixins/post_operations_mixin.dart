import 'dart:async';
import '../../data/models/post_model.dart';
import '../../domain/use_cases/like_use_case.dart';
import '../../domain/use_cases/share_use_case.dart';
import 'package:social_app/core/services/user_account_service.dart';
import 'package:social_app/core/domain/use_cases/post_use_case.dart';


mixin PostOperationsMixin{

  PostUseCase get postUseCase;

  LikeUseCase get likeUseCase;

  ShareUseCase get shareUseCase;

  UserAccountService get userAccountService;

  //Interactions
  Future<void> toggleLike({
    required bool isActive,
    required PostModel postModel,
  }) async {
    try {
      await likeUseCase.toggleLike(isActive: isActive, postModel: postModel);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> addShare({
    required String postId,
    required String userId,
  }) async {
    try {
      await shareUseCase.addShare(postId: postId, userId: userId);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> removeShare({
    required String postId,
    required String userId,
  }) async {
    try {
      await shareUseCase.removeShare(postId: postId, userId: userId);
    } catch (e) {
      rethrow;
    }
  }

  //Post
  Future<void> upsertPostToRepository({
    required PostModel postModel
  }) async {
    var newPost = postModel;
    if (newPost.userIdIsEmpty) {
      final userModel = await userAccountService.getUserAccountData();
      newPost = postModel.copyWith(
        myId: userModel.myId,
        postType: postModel.postType,
      );
    }
    await postUseCase.executeInsertPost(newPost);
  }

  Future<void> removePostFromRepository({
    required PostModel postModel
  }) async {
    await postUseCase.executeRemovePost(
      postModel: postModel,
    );
  }
}