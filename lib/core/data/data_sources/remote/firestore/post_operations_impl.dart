import 'package:social_app/core/data/models/my_model.dart';
import 'package:social_app/core/constants/app_strings.dart';
import 'package:social_app/core/services/data/session_service.dart';
import '../../../../domain/data_sources/remote/firestore/post_operations.dart';
import 'package:social_app/core/data/data_sources/remote/firestore/firestore_service_impl.dart';


class PostOperationsImpl extends FirestoreServiceImpl implements PostOperations {
  final SessionService _sessionService;

  PostOperationsImpl({
    required SessionService sessionService
  }) : _sessionService = sessionService;

  @override
  Future<void> addLike({
    required String postId,
    required String userId,
  }) async {
    final docRef = getDocRef(docId: postId, collectionPath: AppStrings.posts);

    if (userId == _sessionService.currentUid) {
      await docRef.update({AppStrings.isActive: true});
    }

    final action = docRef.collection(AppStrings.likesList).doc(userId);
    final userModel = MyModel(
      myId: userId,
      myDateTime: DateTime.now(),
    );

    await action.set(userModel.toJson());
  }

  @override
  Future<void> removeLike({
    required String postId,
    required String userId,
  }) async {
    final docRef = getDocRef(docId: postId, collectionPath: AppStrings.posts);

    if (userId == _sessionService.currentUid) {
      await docRef.update({AppStrings.isActive: false});
    }

    final action = docRef.collection(AppStrings.likesList).doc(userId);
    await action.delete();
  }

  @override
  Future<void> addShare({
    required String postId,
    required String userId,
  }) async {
    final docRef = getDocRef(docId: postId, collectionPath: AppStrings.posts);

    if (userId == _sessionService.currentUid) {
      await docRef.update({AppStrings.isActive: true});
    }

    final action = docRef.collection(AppStrings.sharesList).doc(userId);
    final userModel = MyModel(
      myId: userId,
      myDateTime: DateTime.now(),
    );

    await action.set(userModel.toJson());
  }

  @override
  Future<void> removeShare({
    required String postId,
    required String userId,
  }) async {
    final docRef = getDocRef(docId: postId, collectionPath: AppStrings.posts);

    if (userId == _sessionService.currentUid) {
      await docRef.update({AppStrings.isActive: false});
    }

    final action = docRef.collection(AppStrings.sharesList).doc(userId);
    await action.delete();
  }
}