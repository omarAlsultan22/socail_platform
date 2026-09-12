import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../../core/data/data_sources/remote/firestore/firestore_base_service.dart';


class FirestoreNotificationsService extends FirestoreBaseService {
  Stream<QuerySnapshot<Map<String, dynamic>>> getNotificationsStream({
    required String userId,
  }) {
    return firestore
        .collection('notifications')
        .where('userId', isEqualTo: userId)
        .orderBy('dateTime', descending: true)
        .snapshots()
        .timeout(duration);
  }

  Future<({
  DocumentSnapshot<Map<String, dynamic>> postDoc,
  DocumentSnapshot<Map<String, dynamic>> userDoc,
  QuerySnapshot<Map<String, dynamic>> commentsDocs
  })> getPostData({
    required String postId,
    required String userId,
  }) async {
    final postRef = firestore.collection('posts').doc(postId);

    final results = await Future.wait([
      postRef.get().timeout(duration),
      getSupDoc(docId: userId, collectionPath: 'accounts'),
      postRef.collection('commentsList').get().timeout(duration),
    ]);

    return (
    postDoc: results[0] as DocumentSnapshot<Map<String, dynamic>>,
    userDoc: results[1] as DocumentSnapshot<Map<String, dynamic>>,
    commentsDocs: results[2] as QuerySnapshot<Map<String, dynamic>>
    );
  }

  Future<int> getPostLikesCount({
    required String postId,
  }) async {
    final likesCount = await firestore
        .collection('posts')
        .doc(postId)
        .collection('likesList')
        .count()
        .get()
        .timeout(duration);
    return likesCount.count ?? 0;
  }

  Future<
      List<QueryDocumentSnapshot<Map<String, dynamic>>>> getCommentsWithLikes({
    required String postId,
    required QuerySnapshot<Map<String, dynamic>> commentsDocs,
  }) async {
    final commentsWithLikes = await Future.wait(
      commentsDocs.docs.map((doc) async {
        final likesCount = await firestore
            .collection('posts')
            .doc(postId)
            .collection('commentsList')
            .doc(doc.id)
            .collection('likesList')
            .count()
            .get()
            .timeout(duration);

        final commentData = doc.data();
        commentData['likesNumber'] = likesCount.count;
        return doc;
      }),
    );
    return commentsWithLikes;
  }

  Future<Map<String, dynamic>> getAccountMap({
    required DocumentSnapshot<Map<String, dynamic>> userDoc,
  }) async {
    final userData = userDoc.data() as Map<String, dynamic>;
    return {
      'userId': userDoc.id,
      'userName': userData['userName'] ?? '',
      'userImage': userData['userImage'] ?? ''
    };
  }
}

