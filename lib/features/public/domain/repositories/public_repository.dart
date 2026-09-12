import 'package:social_app/core/data/models/post_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


abstract class PublicRepository {

  Future<QuerySnapshot> fetchPostsQuery({
    required List<String> friendsUIds,
    required DocumentSnapshot? lastPostDoc,
    required int limit,
  });

  Future<QuerySnapshot> getFriendsForStatus({
    required DocumentSnapshot? lastStatusDoc,
    required int limit,
  });

  Future<void> addToDeletedPosts(String postId);

  Future<void> addToDeletedStatuses(String statusId);

  Future<void> deletePostFromFirestore(String postId);

  Future<void> addPostToFirestore(PostModel postModel);

  Future<DocumentSnapshot> getAccountData(String userId);

  Future<void> deleteStatusFromFirestore(String statusId);

  Future<QuerySnapshot> getStatusesForUser(String userId);

  Future<void> addStatusToFirestore(PostModel statusModel);

  Future<QuerySnapshot<Map<String, dynamic>>> getFriendsList();

  Future<QuerySnapshot<Map<String, dynamic>>> getDeletedPosts();

  Future<QuerySnapshot<Map<String, dynamic>>> getDeletedStatuses();

  Future<Map<String, dynamic>> getAccountMap(DocumentSnapshot userDoc);

  Future<({int? commentsCount, int? likesCount})> getPostCounts(String postId);
}