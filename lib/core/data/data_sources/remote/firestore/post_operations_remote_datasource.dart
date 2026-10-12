import 'package:social_app/core/data/models/my_model.dart';
import 'package:social_app/core/services/session_service.dart';
import 'package:social_app/core/data/data_sources/remote/firestore/firestore_base_service.dart';


abstract class PostOperationsRemoteDataSource extends FirestoreBaseService{
  Future<void> addLike({required String postId, required String userId});
  Future<void> removeLike({required String postId, required String userId});
  Future<void> addShare({required String postId, required String userId});
  Future<void> removeShare({required String postId, required String userId});
}


class PostOperationsRemoteDataSourceImpl extends PostOperationsRemoteDataSource {
  final SessionService _sessionService;

  PostOperationsRemoteDataSourceImpl({
    required SessionService sessionService
  }) : _sessionService = sessionService;

  @override
  Future<void> addLike({
    required String postId,
    required String userId,
  }) async {
    try {
      final docRef = getDocRef(docId: postId, collectionPath: 'posts');

      if (userId == _sessionService.currentUid) {
        await docRef.update({'isActive': true});
      }

      final action = docRef.collection('likesList').doc(userId);
      final userModel = MyModel(
        myId: userId,
        myDateTime: DateTime.now(),
      );

      await action.set(userModel.toJson());
    } catch (e) {
      print('Error inserting like: $e');
      rethrow;
    }
  }

  @override
  Future<void> removeLike({
    required String postId,
    required String userId,
  }) async {
    try {
      final docRef = getDocRef(docId: postId, collectionPath: 'posts');

      if (userId == _sessionService.currentUid) {
        await docRef.update({'isActive': false});
      }

      final action = docRef.collection('likesList').doc(userId);
      await action.delete();
    } catch (e) {
      print('Error deleting like: $e');
      rethrow;
    }
  }

  @override
  Future<void> addShare({
    required String postId,
    required String userId,
  }) async {
    try {
      final docRef = getDocRef(docId: postId, collectionPath: 'posts');

      if (userId == _sessionService.currentUid) {
        await docRef.update({'isActive': true});
      }

      final action = docRef.collection('sharesList').doc(userId);
      final userModel = MyModel(
        myId: userId,
        myDateTime: DateTime.now(),
      );

      await action.set(userModel.toJson());
    } catch (e) {
      print('Error inserting like: $e');
      rethrow;
    }
  }

  @override
  Future<void> removeShare({
    required String postId,
    required String userId,
  }) async {
    try {
      final docRef = getDocRef(docId: postId, collectionPath: 'posts');

      if (userId == _sessionService.currentUid) {
        await docRef.update({'isActive': false});
      }

      final action = docRef.collection('sharesList').doc(userId);
      await action.delete();
    } catch (e) {
      print('Error deleting like: $e');
      rethrow;
    }
  }
}