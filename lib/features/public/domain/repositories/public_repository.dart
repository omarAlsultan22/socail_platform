import 'package:social_app/core/data/models/post_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


abstract class PublicRepository {

  Future<QuerySnapshot> fetchPostsQuery({
    required List<String> friendsUIds,
    required DocumentSnapshot? lastPostDoc,
    required int limit,
  });

  Future<QuerySnapshot> getDeletedPosts();

  Future<DocumentSnapshot> getAccountData(String userId);

  Future<QuerySnapshot> getFriendsForStatus({
    required DocumentSnapshot? lastStatusDoc,
    required int limit,
  });

  Future<QuerySnapshot> getDeletedStatuses();

  Future<QuerySnapshot> getStatusesForUser(String userId);

  Future<void> addPostToFirestore(PostModel postModel);

  Future<void> addStatusToFirestore(PostModel statusModel);

  Future<void> deletePostFromFirestore(String postId);

  Future<void> addToDeletedPosts(String postId);

  Future<void> deleteStatusFromFirestore(String statusId);

  Future<void> addToDeletedStatuses(String statusId);

  Future<QuerySnapshot> getFriendsList({required String uId});

  Future<Map<String, dynamic>> getAccountMap(DocumentSnapshot userDoc);

  Future<({int? commentsCount, int? likesCount})> getPostCounts(String postId);
}