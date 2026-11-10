import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:social_app/core/data/models/my_model.dart';
import 'package:social_app/core/data/models/comment_model.dart';
import 'package:social_app/features/post_detail/domain/repositories/post_detail_repository.dart';


class FakePostDetailRepository implements PostDetailRepository {
  // ===== getPostData =====
  ({
  DocumentSnapshot postDoc,
  DocumentSnapshot userDoc,
  QuerySnapshot<Map<String, dynamic>> commentsDocs
  })? getPostDataResult;
  int getPostDataCallCount = 0;

  @override
  Future<({
  DocumentSnapshot postDoc,
  DocumentSnapshot userDoc,
  QuerySnapshot<Map<String, dynamic>> commentsDocs
  })> getPostData({
    required String postId,
    required String userId,
  }) async {
    getPostDataCallCount++;
    return getPostDataResult!;
  }

  // ===== getPostLikes =====
  int? getPostLikesResult = 0;
  int getPostLikesCallCount = 0;

  @override
  Future<int?> getPostLikes({required String postId}) async {
    getPostLikesCallCount++;
    return getPostLikesResult;
  }

  // ===== getCommentsWithUsers =====
  List<CommentModel> getCommentsWithUsersResult = [];
  int getCommentsWithUsersCallCount = 0;

  @override
  Future<List<CommentModel>> getCommentsWithUsers({
    required String postId,
    required QuerySnapshot<Map<String, dynamic>> commentsDocs,
  }) async {
    getCommentsWithUsersCallCount++;
    return getCommentsWithUsersResult;
  }

  // ===== insertNotification =====
  int insertNotificationCallCount = 0;
  MyModel? lastNotificationData;

  @override
  Future<void> insertNotification({required MyModel notificationData}) async {
    insertNotificationCallCount++;
    lastNotificationData = notificationData;
  }

  // ===== hasMeLiked =====
  bool hasMeLikedResult = false;
  int hasMeLikedCallCount = 0;

  @override
  Future<bool> hasMeLiked(String postId) async {
    hasMeLikedCallCount++;
    return hasMeLikedResult;
  }

  // باقي الدوال — noSuchMethod
  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError(
        'FakePostDetailRepository.${invocation.memberName} not stubbed',
      );
}