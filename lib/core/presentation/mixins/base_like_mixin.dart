import '../../services/session_service.dart';
import 'package:social_app/core/data/data_sources/remote/firestore/firestore_base_service.dart';


mixin BaseLikeMixin {
  String get likeCollectionPath;

  SessionService get sessionService;

  FirestoreBaseService get repository;

  Future<bool> hasMeLiked(String postId) async {
    final postRef = repository.getDocRef(
        docId: postId, collectionPath: 'posts'
    );
    final doc = await repository.getSpecificDocRef(
        docRef: postRef,
        docId: sessionService.currentUid,
        collectionPath: likeCollectionPath
    ).get();
    return doc.exists;
  }
}