import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:social_app/core/constants/app_strings.dart';
import '../../domain/data_sources/post_detail_data_source.dart';
import '../../../../core/data/data_sources/remote/firestore/firestore_service_impl.dart';


class PostDetailDataSourceImpl extends FirestoreServiceImpl implements PostDetailDataSource {

  @override
  Future<({
  DocumentSnapshot<Map<String, dynamic>> postDoc,
  DocumentSnapshot<Map<String, dynamic>> userDoc,
  QuerySnapshot<Map<String, dynamic>> commentsDocs
  })> getPostData({
    required String postId,
    required String userId,
  }) async {
    final postRef = getDocRef(docId: postId, collectionPath: AppStrings.posts);

    final results = await Future.wait([
      postRef.get().timeout(duration),
      getDoc(docId: userId, collectionPath: AppStrings.accounts),
      postRef.collection(AppStrings.commentsList).get().timeout(duration),
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
        final postRef = getDocRef(
            docId: postId, collectionPath: AppStrings.posts);
        final commentRef = getSpecificDocRef(
            docId: doc.id,
            collectionPath: AppStrings.commentsList,
            docRef: postRef);
        final likesCount = await getCount(
            collectionPath: AppStrings.commentsLikes, docRef: commentRef);
        final commentData = doc.data();
        commentData[AppStrings.likesNumber] = likesCount.count;
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
      AppStrings.userId: userDoc.id,
      AppStrings.userName: userData[AppStrings.userName] ?? AppStrings.empty,
      AppStrings.userImage: userData[AppStrings.userImage] ?? AppStrings.empty
    };
  }
}

