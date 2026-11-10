import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:social_app/features/user_details/domain/data_sources/user_details_data_source.dart';


class FakeUserDetailsDataSource implements UserDetailsDataSource {
  // ===== getMyDetailsStream =====
  Stream<DocumentSnapshot<Map<String, dynamic>>>? myDetailsStream;
  int getMyDetailsCallCount = 0;
  String? lastMyDetailsDocId;
  String? lastMyDetailsCollectionPath;

  @override
  Stream<DocumentSnapshot<Map<String, dynamic>>> getMyDetailsStream({
    required String docId,
    required String collectionPath,
  }) {
    getMyDetailsCallCount++;
    lastMyDetailsDocId = docId;
    lastMyDetailsCollectionPath = collectionPath;
    return myDetailsStream!;
  }

  // ===== getSubCollectionStream =====
  Stream<QuerySnapshot<Map<String, dynamic>>>? subCollectionStream;
  int getSubCollectionCallCount = 0;
  String? lastSubDocId;
  String? lastSubSupCollectionPath;
  String? lastSubSubCollectionPath;

  @override
  Stream<QuerySnapshot<Map<String, dynamic>>> getSubCollectionStream({
    required String docId,
    required String supCollectionPath,
    required String subCollectionPath,
  }) {
    getSubCollectionCallCount++;
    lastSubDocId = docId;
    lastSubSupCollectionPath = supCollectionPath;
    lastSubSubCollectionPath = subCollectionPath;
    return subCollectionStream!;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError(
        'FakeUserDetailsDataSource.${invocation.memberName} not stubbed',
      );
}