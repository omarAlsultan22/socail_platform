import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/domain/data_sources/remote/firestore/firestore_service.dart';


abstract class PostDetailDataSource extends FirestoreService {

  Future<({
  DocumentSnapshot<Map<String, dynamic>> postDoc,
  DocumentSnapshot<Map<String, dynamic>> userDoc,
  QuerySnapshot<Map<String, dynamic>> commentsDocs
  })> getPostData({
    required String postId,
    required String userId,
  });

  Future<
      List<QueryDocumentSnapshot<Map<String, dynamic>>>> getCommentsWithLikes({
    required String postId,
    required QuerySnapshot<Map<String, dynamic>> commentsDocs,
  });

  Future<Map<String, dynamic>> getAccountMap({
    required DocumentSnapshot<Map<String, dynamic>> userDoc,
  });
}

