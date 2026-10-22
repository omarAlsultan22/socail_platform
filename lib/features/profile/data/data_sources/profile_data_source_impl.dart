import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/data/models/post_model.dart';
import '../../../../core/data/posts/constants/posts_collection.dart';
import 'package:social_app/core/data/posts/queries/posts_query_builder.dart';
import '../../../../core/data/data_sources/remote/firestore/firestore_service_impl.dart';
import 'package:social_app/features/profile/domain/data_sources/profile_data_source.dart';


class ProfileDataSourceImpl extends FirestoreServiceImpl implements ProfileDataSource {

  @override
  Future<String> createAndSetDoc({
    bool merge = true,
    required String collectionPath,
    required Map<String, dynamic> data,
  }) async {
    final docRef = firestore.collection(collectionPath).doc();
    await docRef.set(data, SetOptions(merge: merge)).timeout(duration);
    return docRef.id;
  }

  @override
  DocumentReference<Map<String, dynamic>> createDoc({
    required String collectionPath
  }) {
    final docRef = firestore.collection(collectionPath).doc();
    return docRef;
  }

  @override
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

  @override
  Future<QuerySnapshot> getPosts({
    String? postType,
    required int limit,
    required String userId,
    required DocumentSnapshot? lastPostDoc,
  }) async {
    var query = firestore
        .collection('posts')
        .where('userId', isEqualTo: userId)
        .where(
        'postType', whereIn: [postType ?? PostsCollection.postTypesList]);

    return PostsQueryBuilder.build(
        limit: limit,
        baseQuery: query,
        lastPostDoc: lastPostDoc
    ).get();
  }

  @override
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

    postModel.myDocId = docRef.id;
    await docRef.set(postModel.postToMap(), SetOptions(merge: true));
    return
      docRef.id;
  }
}

