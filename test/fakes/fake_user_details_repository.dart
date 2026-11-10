import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:social_app/features/user_details/domain/repositories/user_details_repository.dart';


class FakeUserDetailsRepository implements UserDetailsRepository {
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

  Stream<QuerySnapshot<Map<String, dynamic>>>? friendsListStream;
  int getFriendsListCallCount = 0;
  String? lastFriendsListUid;

  @override
  Stream<QuerySnapshot<Map<String, dynamic>>> getFriendsList(String currentUid) {
    getFriendsListCallCount++;
    lastFriendsListUid = currentUid;
    return friendsListStream!;
  }
}