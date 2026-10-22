import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/domain/data_sources/remote/firestore/firestore_service.dart';


abstract class PublicDataSource extends FirestoreService {
  Future<QuerySnapshot<Map<String, dynamic>>> getQuery({
    required int limit,
    required String docId,
    required String supCollectionPath,
    required String subCollectionPath,
    required DocumentSnapshot? lastStatusDoc,
  });

  Future<QuerySnapshot<Map<String, dynamic>>> getStatusesByUser({
    required String userId,
  });

  Future<QuerySnapshot> getDocumentsWithWhereIn({
    required DocumentSnapshot? lastPostDoc,
    required List<String> friendsUIds,
    required int limit,
  });

  Future<({int? commentsCount, int? likesCount})> getPostCounts(
      String postId);
}

