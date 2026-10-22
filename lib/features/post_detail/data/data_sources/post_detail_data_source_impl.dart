import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/data_sources/post_detail_data_source.dart';
import '../../../../core/data/data_sources/remote/firestore/firestore_service_impl.dart';


class PostDetailDataSourceImpl extends FirestoreServiceImpl implements PostDetailDataSource{

  @override
  Future<({
  DocumentSnapshot<Map<String, dynamic>> postDoc,
  DocumentSnapshot<Map<String, dynamic>> userDoc,
  QuerySnapshot<Map<String, dynamic>> commentsDocs
  })> getPostData({
    required String postId,
    required String userId,
  }) async {
    final postRef = getDocRef(docId: postId, collectionPath: 'posts');

    final results = await Future.wait([
      postRef.get().timeout(duration),
      getDoc(docId: userId, collectionPath: 'accounts'),
      postRef.collection('commentsList').get().timeout(duration),
    ]);

    return (
    postDoc: results[0] as DocumentSnapshot<Map<String, dynamic>>,
    userDoc: results[1] as DocumentSnapshot<Map<String, dynamic>>,
    commentsDocs: results[2] as QuerySnapshot<Map<String, dynamic>>
    );
  }

  @override
  Future<
      List<QueryDocumentSnapshot<Map<String, dynamic>>>> getCommentsWithLikes({
    required String postId,
    required QuerySnapshot<Map<String, dynamic>> commentsDocs,
  }) async {
    final commentsWithLikes = await Future.wait(
      commentsDocs.docs.map((doc) async {
        final postRef = getDocRef(docId: postId, collectionPath: 'posts');
        final commentRef = getSpecificDocRef(
            docId: doc.id, collectionPath: 'commentsList', docRef: postRef);
        final likesCount = await getCount(
            collectionPath: 'commentsLikes', docRef: commentRef);
        final commentData = doc.data();
        commentData['likesNumber'] = likesCount.count;
        return doc;
      }),
    );
    return commentsWithLikes;
  }

  @override
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

