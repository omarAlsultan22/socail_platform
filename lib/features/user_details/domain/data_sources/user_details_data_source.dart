import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/domain/data_sources/remote/firestore/firestore_service.dart';


abstract class UserDetailsDataSource extends FirestoreService{
  Stream<DocumentSnapshot<Map<String, dynamic>>> getMyDetailsStream({
    required String docId,
    required String collectionPath,
  });
}