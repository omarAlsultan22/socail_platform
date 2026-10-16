import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:social_app/core/data/data_sources/remote/firestore/firestore_base_service.dart';


class UserDetailsRemoteDataSource extends FirestoreBaseService{
  Stream<DocumentSnapshot<Map<String, dynamic>>> getMyDetailsStream({
    required String docId,
    required String collectionPath,
  }) {
    return firestore.collection(collectionPath).doc(docId).snapshots().timeout(
        duration);
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getSubCollectionStream({
    required String docId,
    required String supCollectionPath,
    required String subCollectionPath,
  }) {
    return firestore
        .collection(supCollectionPath)
        .doc(docId)
        .collection(subCollectionPath)
        .snapshots().timeout(duration);
  }
}