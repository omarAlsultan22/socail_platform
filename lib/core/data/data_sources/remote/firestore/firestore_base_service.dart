import '../../../../constants/app_durations.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class FirestoreBaseService {
  final firestore = FirebaseFirestore.instance;
  final duration = AppDurations.seconds;

  Future<String> getRefAndSetDoc({
    String? docId,
    required bool isMerge,
    required String collectionPath,
    required Map<String, dynamic> data,
  }) async {
    DocumentReference ref;
    if (docId != null) {
      ref = firestore.collection(collectionPath).doc(docId);
    } else {
      ref = firestore.collection(collectionPath).doc();
    }
    await ref.set(data, SetOptions(merge: isMerge)).timeout(duration);
    return ref.id;
  }

  DocumentReference<Map<String, dynamic>> docRef({
    required String docId,
    required String collectionPath
  }) {
    final docRef = firestore.collection(collectionPath).doc(docId);
    return docRef;
  }

  Future<QuerySnapshot<Map<String, dynamic>>> getSupCollection({
    required String collectionPath,
  }) {
    return firestore
        .collection(collectionPath).get();
  }

  Future<QuerySnapshot<Map<String, dynamic>>> getSubCollection({
    required String docId,
    required String supCollectionPath,
    required String subCollectionPath,
  }) {
    return firestore
        .collection(supCollectionPath)
        .doc(docId)
        .collection(subCollectionPath).get();
  }

  Future<void> updateDoc({
    required String? docId,
    required String collectionPath,
    required Map<String, dynamic> data,
  }) async {
    await firestore.collection(collectionPath).doc(docId).update(data).timeout(
        duration);
  }

  Future<void> deleteSupDoc({
    required String collectionPath,
    required String docId,
  }) async {
    await firestore.collection(collectionPath).doc(docId).delete().timeout(
        duration);
  }

  Future<void> deleteSubDoc({
    required String? supDoc,
    required String? subDoc,
    required String supCollectionPath,
    required String subCollectionPath,
  }) async {
    await firestore.collection(supCollectionPath).doc(supDoc).collection(
        subCollectionPath).doc(subDoc).delete().timeout(
        duration);
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> getSupDoc({
    required String docId,
    required String collectionPath,
  }) async {
    return await firestore.collection(collectionPath).doc(docId).get().timeout(
        duration);
  }

  Future<void> setSupDoc({
    String? docId,
    required bool isMerge,
    required String collectionPath,
    required Map<String, dynamic> data,
  }) async {
    await firestore.collection(collectionPath).doc(docId).set(
        data, SetOptions(merge: isMerge)).timeout(
        duration);
  }

  Future<void> setSubDoc({
    required String? supDocId,
    required String? subDocId,
    required String supCollectionPath,
    required String subCollectionPath,
    required Map<String, dynamic> data,
  }) async {
    await firestore.collection(supCollectionPath).doc(supDocId).collection(
        subCollectionPath).doc(subDocId).set(data).timeout(duration
    );
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
        .snapshots()
        .timeout(duration);
  }
}
