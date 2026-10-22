import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/data/models/post_model.dart';
import '../../../../core/domain/data_sources/remote/firestore/firestore_service.dart';


abstract class ProfileDataSource extends FirestoreService {
  Future<String> createAndSetDoc({
    bool merge = true,
    required String collectionPath,
    required Map<String, dynamic> data,
  });

  DocumentReference<Map<String, dynamic>> createDoc({
    required String collectionPath
  });

  Future<DocumentSnapshot<Map<String, dynamic>>> getSubDoc({
    required String supDoc,
    required String subDoc,
    required String supCollectionPath,
    required String subCollectionPath,
  });

  Future<QuerySnapshot> getPosts({
    String? postType,
    required int limit,
    required String userId,
    required DocumentSnapshot? lastPostDoc,
  });

  Future<String> uploadImage({
    required String imageType,
    required String currentUid,
    required PostModel postModel,
    required String collectionPath,
  });
}

