import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/data_sources/user_details_data_source.dart';
import 'package:social_app/features/user_details/domain/repositories/user_details_repository.dart';


class UserDetailsRepositoryImpl implements UserDetailsRepository {
  final UserDetailsDataSource _dataSource;

  UserDetailsRepositoryImpl({
    required UserDetailsDataSource
    dataSource}) : _dataSource = dataSource;

  @override
  Stream<DocumentSnapshot<Map<String, dynamic>>> getMyDetailsStream({
    required String docId,
    required String collectionPath,
  }) {
    return _dataSource.getMyDetailsStream(
      docId: docId,
      collectionPath: collectionPath,
    );
  }

  @override
  Stream<QuerySnapshot<Map<String, dynamic>>> getFriendsList(
      String currentUid) {
    return _dataSource.getSubCollectionStream(
        docId: currentUid,
        supCollectionPath: 'users',
        subCollectionPath: 'friends'
    );
  }
}