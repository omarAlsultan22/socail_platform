import 'package:social_app/core/data/models/post_model.dart';


abstract class PostRepository {

  Future<void> addLike({
    required String postId,
    required String userId,
  });

  Future<void> removeLike({
    required String postId,
    required String userId,
  });

  Future<void> addShare({
    required String postId,
    required String userId,
  });

  Future<void> removeShare({
    required String postId,
    required String userId,
  });

  Future<void> deletePostFromFirestore(String postId);

  Future<void> upsertPostToFirestore(PostModel postModel);

  Future<void> upsertToDeletedPosts(String postId, String currentUid);
}