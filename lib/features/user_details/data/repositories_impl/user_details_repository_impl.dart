import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../data_sources/remote/user_details_remote_data_source.dart';


class UserDetailsRepositoryImpl {
  final UserDetailsRemoteDataSource _dataSourceImpl;

  UserDetailsRepositoryImpl({
    required UserDetailsRemoteDataSource
    dataSourceImpl}) : _dataSourceImpl = dataSourceImpl;

  Stream<DocumentSnapshot<Map<String, dynamic>>> getMyDetailsStream({
    required String docId,
    required String collectionPath,
  }) {
    return _dataSourceImpl.getMyDetailsStream(
      docId: docId,
      collectionPath: collectionPath,
    );
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getFriendsList(String currentUid){
    return _dataSourceImpl.getSubCollectionStream(
      docId: currentUid,
      supCollectionPath: 'users',
      subCollectionPath: 'friends'
    );
  }
}