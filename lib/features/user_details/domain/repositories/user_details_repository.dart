import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';


abstract class UserDetailsRepository {
  Stream<DocumentSnapshot<Map<String, dynamic>>> getMyDetailsStream({
    required String docId,
    required String collectionPath,
  });

  Stream<QuerySnapshot<Map<String, dynamic>>> getFriendsList(String currentUid);
}