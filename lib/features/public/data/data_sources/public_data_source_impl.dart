import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/constants/firestore_schema.dart';
import 'package:social_app/core/constants/app_strings.dart';
import '../../../../core/data/posts/constants/posts_collection.dart';
import 'package:social_app/features/public/constants/public_constants.dart';
import 'package:social_app/core/data/posts/queries/posts_query_builder.dart';
import 'package:social_app/features/public/domain/data_sources/public_data_source.dart';
import '../../../../core/data/data_sources/remote/firestore/firestore_service_impl.dart';


class PublicDataSourceImpl extends FirestoreServiceImpl implements PublicDataSource {
  final FirebaseFirestore _firestore;
  PublicDataSourceImpl({super.firestore}) : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<QuerySnapshot<Map<String, dynamic>>> getQuery({
    required int limit,
    required String docId,
    required String supCollectionPath,
    required String subCollectionPath,
    required DocumentSnapshot? lastStatusDoc,
  }) async {
    Query<Map<String, dynamic>> query = _firestore
        .collection(supCollectionPath)
        .doc(docId)
        .collection(subCollectionPath);

    if (lastStatusDoc != null) {
      query = query.startAfterDocument(lastStatusDoc);
    }

    return await query.limit(limit).get();
  }

  @override
  Future<QuerySnapshot<Map<String, dynamic>>> getStatusesByUser({
    required String userId,
  }) async {
    return await _firestore
        .collection(PublicConstants.status)
        .where(AppStrings.userId, isEqualTo: userId)
        .orderBy(AppStrings.dateTime, descending: true)
        .get()
        .timeout(duration);
  }

  @override
  Future<QuerySnapshot> getDocumentsWithWhereIn({
    required DocumentSnapshot? lastPostDoc,
    required List<String> friendsUIds,
    required int limit,
  }) async {
    var query = _firestore
        .collection(FirestoreSchema.posts)
        .where(AppStrings.userId, whereIn: friendsUIds)
        .where(AppStrings.postType, whereIn: PostsCollection.postTypesList);

    return PostsQueryBuilder.build(
        limit: limit,
        baseQuery: query,
        lastPostDoc: lastPostDoc
    ).get();
  }

  @override
  Future<({int? commentsCount, int? likesCount})> getPostCounts(
      String postId) async {
    final postRef = getDocRef(
        docId: postId,
        collectionPath: FirestoreSchema.posts
    );
    final results = await Future.wait([
      getCount(docRef: postRef, collectionPath: AppStrings.likesList),
      getCount(docRef: postRef, collectionPath: AppStrings.commentsList),
    ]);
    return (
    likesCount: results[0].count,
    commentsCount: results[1].count,
    );
  }
}

