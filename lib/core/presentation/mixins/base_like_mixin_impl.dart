import '../../services/data/session_service.dart';
import 'package:social_app/core/constants/app_strings.dart';
import '../../domain/data_sources/remote/firestore/firestore_service.dart';


mixin BaseLikeMixinImpl {
  String get likeCollectionPath;

  FirestoreService get dataSource;

  SessionService get sessionService;

  Future<bool> hasMeLiked(String postId) async {
    final postRef = dataSource.getDocRef(
        docId: postId, collectionPath: AppStrings.posts
    );
    final doc = await dataSource.getSpecificDocRef(
        docRef: postRef,
        docId: sessionService.currentUid,
        collectionPath: likeCollectionPath
    ).get();
    return doc.exists;
  }
}