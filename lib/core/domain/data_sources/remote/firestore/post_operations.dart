import 'firestore_service.dart';


abstract class PostOperations extends FirestoreService {
  Future<void> addLike({required String postId, required String userId});

  Future<void> removeLike({required String postId, required String userId});

  Future<void> addShare({required String postId, required String userId});

  Future<void> removeShare({required String postId, required String userId});
}
