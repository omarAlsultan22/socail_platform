import '../../domain/repositories/post_repository.dart';
import 'package:social_app/core/constants/app_strings.dart';
import 'package:social_app/core/data/models/post_model.dart';
import '../../domain/data_sources/remote/firestore/post_operations.dart';


class PostRepositoryImpl extends PostRepository {
  final PostOperations _repository;

  PostRepositoryImpl({
    required PostOperations repository
  })
      : _repository = repository;

  @override
  Future<void> addLike({required String postId, required String userId}) async {
    await _repository.addLike(postId: postId, userId: userId);
  }

  @override
  Future<void> removeLike(
      {required String postId, required String userId}) async {
    await _repository.removeLike(postId: postId, userId: userId);
  }

  @override
  Future<void> addShare(
      {required String postId, required String userId}) async {
    await _repository.addShare(postId: postId, userId: userId);
  }

  @override
  Future<void> removeShare(
      {required String postId, required String userId}) async {
    await _repository.removeShare(postId: postId, userId: userId);
  }

  @override
  Future<void> upsertPostToFirestore(PostModel postModel) async {
    await _repository.getRefAndSetDoc(
      isMerge: true,
      docId: postModel.myDocId,
      collectionPath: AppStrings.posts,
      data: postModel.toJson(),
    );
  }

  @override
  Future<void> upsertToDeletedPosts(String postId, String currentUid) async {
    await _repository.setSubDoc(
      data: {},
      subDocId: postId,
      supDocId: currentUid,
      supCollectionPath: AppStrings.users,
      subCollectionPath: AppStrings.deletedPosts,
    );
  }

  @override
  Future<void> deletePostFromFirestore(String postId) async {
    await _repository.deleteSupDoc(
        collectionPath: AppStrings.posts, docId: postId);
  }
}