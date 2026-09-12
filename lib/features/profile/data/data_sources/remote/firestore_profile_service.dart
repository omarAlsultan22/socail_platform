import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../../core/data/data_sources/remote/firestore/firestore_base_service.dart';
import '../../../../../core/data/models/post_model.dart';


class FirestoreProfileService extends FirestoreBaseService {
  Future<String> createAndSetDoc({
    bool merge = true,
    required String collectionPath,
    required Map<String, dynamic> data,
  }) async {
    final docRef = firestore.collection(collectionPath).doc();
    await docRef.set(data, SetOptions(merge: merge)).timeout(duration);
    return docRef.id;
  }

  DocumentReference<Map<String, dynamic>> createDoc({
    required String collectionPath
  }) {
    final docRef = firestore.collection(collectionPath).doc();
    return docRef;
  }

  Future<AggregateQuerySnapshot> getCount({
    required String collectionPath,
    required DocumentReference docRef
  }) {
    return docRef.collection(collectionPath).count().get();
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> getSubDoc({
    required String supDoc,
    required String subDoc,
    required String supCollectionPath,
    required String subCollectionPath,
  }) async {
    return await firestore.collection(supCollectionPath).doc(supDoc)
        .collection(
        subCollectionPath).doc(subDoc).get()
        .timeout(
        duration);
  }

  Future<QuerySnapshot> getPosts({
    required int limit,
    required String userId,
    required String postType,
    required DocumentSnapshot? lastPostDoc,
  }) async {
    var query = firestore
        .collection('posts')
        .where('userId', isEqualTo: userId)
        .where('postType', isEqualTo: postType)
        .orderBy('dateTime', descending: true);

    if (lastPostDoc != null) {
      query = query.startAfterDocument(lastPostDoc);
    }

    return await query.limit(limit).get();
  }

  Future<String> uploadImage({
    required String imageType,
    required String currentUid,
    required PostModel postModel,
    required String collectionPath,
  }) async {
    final docRef = createDoc(collectionPath: 'posts');
    await setSupDoc(
      isMerge: true,
      docId: currentUid,
      collectionPath: collectionPath,
      data: {imageType: docRef.path}
    );

    postModel.docId = docRef.id;
    await docRef.set(postModel.postToMap(), SetOptions(merge: true));
    return
      docRef.id;
  }
}

