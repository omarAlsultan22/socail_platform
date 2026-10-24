import 'package:cloud_firestore/cloud_firestore.dart';


abstract class FirestoreService {
  Future<String> getRefAndSetDoc({
    String? docId,
    required bool isMerge,
    required String collectionPath,
    required Map<String, dynamic> data,
  });

  Future<void> updateDoc({
    required String? docId,
    required String collectionPath,
    required Map<String, dynamic> data,
  });

  Future<void> deleteSupDoc({
    required String collectionPath,
    required String docId,
  });

  Future<void> deleteSubDoc({
    required String? supDoc,
    required String? subDoc,
    required String supCollectionPath,
    required String subCollectionPath,
  });

  Future<void> setSupDoc({
    String? docId,
    required bool isMerge,
    required String collectionPath,
    required Map<String, dynamic> data,
  });

  Future<void> setSubDoc({
    required String? supDocId,
    required String? subDocId,
    required String supCollectionPath,
    required String subCollectionPath,
    required Map<String, dynamic> data,
  });

  DocumentReference getSpecificDocRef({
    required String docId,
    required String collectionPath,
    required DocumentReference docRef
  });

  Future<AggregateQuerySnapshot> getCount({
    required String collectionPath,
    required DocumentReference docRef
  });

  DocumentReference<Map<String, dynamic>> getDocRef({
    required String? docId,
    required String collectionPath
  });

  Future<DocumentSnapshot<Map<String, dynamic>>> getDoc({
    required String docId,
    required String collectionPath,
  });

  Future<QuerySnapshot<Map<String, dynamic>>> getSupCollection({
    required String collectionPath,
  });

  Future<QuerySnapshot<Map<String, dynamic>>> getSubCollection({
    required String docId,
    required String supCollectionPath,
    required String subCollectionPath,
  });

  Stream<QuerySnapshot<Map<String, dynamic>>> getSubCollectionStream({
    required String docId,
    required String supCollectionPath,
    required String subCollectionPath,
  });
}