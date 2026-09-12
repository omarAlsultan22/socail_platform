import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../../core/data/data_sources/remote/firestore/firestore_base_service.dart';


class FirestorePublicService extends FirestoreBaseService {
  Future<QuerySnapshot<Map<String, dynamic>>> getQuery({
    required int limit,
    required String docId,
    required String supCollectionPath,
    required String subCollectionPath,
    required DocumentSnapshot? lastStatusDoc,
  }) async {
    Query<Map<String, dynamic>> query = firestore
        .collection(supCollectionPath)
        .doc(docId)
        .collection(subCollectionPath);

    if (lastStatusDoc != null) {
      query = query.startAfterDocument(lastStatusDoc);
    }

    return await query.limit(limit).get();
  }

  Future<QuerySnapshot<Map<String, dynamic>>> getStatusesByUser({
    required String userId,
  }) async {
    return await firestore
        .collection('status')
        .where('userId', isEqualTo: userId)
        .orderBy('dateTime', descending: true)
        .get()
        .timeout(duration);
  }

  Future<QuerySnapshot> getDocumentsWithWhereIn({
    required DocumentSnapshot? lastPostDoc,
    required List<String> friendsUIds,
    required String postType,
    required int limit,
  }) async {
    var query = firestore
        .collection('posts')
        .where('userId', whereIn: friendsUIds)
        .where('postType', isEqualTo: postType)
        .orderBy('dateTime', descending: true);

    if (lastPostDoc != null) {
      query = query.startAfterDocument(lastPostDoc);
    }
    return await query.limit(limit).get();
  }

  Future<({int? commentsCount, int? likesCount})> getPostCounts(
      String postId) async {
    final postRef = docRef(
        docId: postId,
        collectionPath: 'posts'
    );
    final results = await Future.wait([
      postRef.collection('likesList').count().get(),
      postRef.collection('commentsList').count().get(),
    ]);
    return (
    likesCount: results[0].count,
    commentsCount: results[1].count,
    );
  }
}

