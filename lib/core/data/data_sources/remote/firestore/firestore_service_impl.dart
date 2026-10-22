import '../../../../constants/app_durations.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:social_app/core/domain/data_sources/remote/firestore/firestore_service.dart';


class FirestoreServiceImpl implements FirestoreService{
  final firestore = FirebaseFirestore.instance;
  final duration = AppDurations.seconds;

  @override
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

  @override
  DocumentReference<Map<String, dynamic>> getDocRef({
    required String? docId,
    required String collectionPath
  }) {
    final docRef = firestore.collection(collectionPath).doc(docId);
    return docRef;
  }

  @override
  Future<QuerySnapshot<Map<String, dynamic>>> getSupCollection({
    required String collectionPath,
  }) {
    return firestore
        .collection(collectionPath).get().timeout(duration);
  }

  @override
  Future<QuerySnapshot<Map<String, dynamic>>> getSubCollection({
    required String docId,
    required String supCollectionPath,
    required String subCollectionPath,
  }) {
    return firestore
        .collection(supCollectionPath)
        .doc(docId)
        .collection(subCollectionPath)
        .get().timeout(duration);
  }

  @override
  Future<void> updateDoc({
    required String? docId,
    required String collectionPath,
    required Map<String, dynamic> data,
  }) async {
    await firestore.collection(collectionPath).doc(docId).update(data).timeout(
        duration);
  }

  @override
  Future<void> deleteSupDoc({
    required String collectionPath,
    required String docId,
  }) async {
    await firestore.collection(collectionPath).doc(docId).delete().timeout(
        duration);
  }

  @override
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

  @override
  Future<DocumentSnapshot<Map<String, dynamic>>> getDoc({
    required String docId,
    required String collectionPath,
  }) async {
    return await firestore.collection(collectionPath).doc(docId).get().timeout(
        duration);
  }

  @override
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

  @override
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

  @override
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

  @override
  Future<AggregateQuerySnapshot> getCount({
    required String collectionPath,
    required DocumentReference docRef
  }) {
    return docRef.collection(collectionPath).count().get().timeout(duration);
  }

  @override
  DocumentReference getSpecificDocRef({
    required String docId,
    required String collectionPath,
    required DocumentReference docRef
  }) {
    return docRef.collection(collectionPath).doc(docId);
  }
}
