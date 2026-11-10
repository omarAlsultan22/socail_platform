import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:social_app/core/data/data_sources/remote/firestore/firestore_service_impl.dart';
import 'package:social_app/features/user_details/domain/data_sources/user_details_data_source.dart';


class UserDetailsDataSourceImpl extends FirestoreServiceImpl implements UserDetailsDataSource {
  final FirebaseFirestore _firestore;

  UserDetailsDataSourceImpl({super.firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;


  @override
  Stream<DocumentSnapshot<Map<String, dynamic>>> getMyDetailsStream({
    required String docId,
    required String collectionPath,
  }) {
    return _firestore.collection(collectionPath).doc(docId).snapshots().timeout(
        duration);
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getSubCollectionStream_({
    required String docId,
    required String supCollectionPath,
    required String subCollectionPath,
  }) {
    return getSubCollectionStream(
        docId: docId,
        supCollectionPath: supCollectionPath,
        subCollectionPath: subCollectionPath
    );
  }
}