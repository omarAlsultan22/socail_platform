import 'dart:async';
import 'package:social_app/core/data/models/post_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/constants/user_details.dart';
import '../../../../services/online_status_service.dart';
import '../../../../shared/componentes/public_components.dart';
import '../../data/repositories_impl/firestore_public_repository.dart';


class PublicUseCases {

  final PublicRepository _repository;

  PublicUseCases({required PublicRepository repository})
      : _repository = repository;

  // جلب البوستات الرئيسية
  Future<({bool hasMore, DocumentSnapshot<Object?>? lastDoc, List<dynamic> posts})> executeGetHomePosts({
    required DocumentSnapshot? lastPostDoc,
    required bool hasMorePosts,
  }) async {
    if (!hasMorePosts) {
      return (posts: [], hasMore: false, lastDoc: lastPostDoc);
    }

    final friendsSnapshot = await _repository.getFriendsList(uId: UserDetails.uId);
    final friendsUIds = friendsSnapshot.docs.postStatuses((doc) => doc.id).toList();
    friendsUIds.add(UserDetails.uId);

    final results = await Future.wait([
      _repository.fetchPostsQuery(
        friendsUIds: friendsUIds,
        lastPostDoc: lastPostDoc,
        limit: 10,
      ),
      _repository.getDeletedPosts(),
    ]);

    final querySnapshot = results[0];
    final deletedPostsSnapshot = results[1];
    final deletedPosts = deletedPostsSnapshot.docs.postStatuses((doc) => doc.id).toList();

    if (querySnapshot.docs.isEmpty) {
      return (posts: [], hasMore: false, lastDoc: lastPostDoc);
    }

    final newLastDoc = querySnapshot.docs.last;
    final List<PostModel> posts = [];

    await Future.wait(querySnapshot.docs.postStatuses((doc) async {
      try {
        if (deletedPosts.contains(doc.id)) return;

        final data = doc.data() as Map<String, dynamic>;
        if (data.isEmpty || !data.containsKey('userId')) return;

        final userId = data['userId'];
        final isActive = data['friendId'] != null;

        final userAccountDoc = await _repository.getAccountData(userId);
        if (!userAccountDoc.exists) return;

        final userAccount = await _repository.getAccountMap(userAccountDoc);

        Map<String, dynamic> friendAccount = {};
        if (isActive) {
          final friendAccountDoc = await _repository.getAccountData(data['friendId']);
          if (friendAccountDoc.exists) {
            friendAccount = await _repository.getAccountMap(friendAccountDoc);
          }
        }

        final counts = await _repository.getPostCounts(doc.id);

        posts.add(
          PostModel.fromFirestoreToPost({
            ...userAccount,
            ...data,
            ...friendAccount,
            'docId': doc.id,
            'likesNumber': counts.likesCount,
            'commentsNumber': counts.commentsCount,
          }),
        );
      } catch (e) {
        // تجاهل الأخطاء الفردية
      }
    }).toList());

    posts.sort((a, b) => b.dateTime!.compareTo(a.dateTime!));

    return (
    posts: posts,
    hasMore: posts.isNotEmpty,
    lastDoc: newLastDoc,
    );
  }

  // جلب الستوريس
  Future<({bool hasMore, DocumentSnapshot<Object?>? lastDoc, List<dynamic> myStatuses, List<dynamic> statuses})> executeGetHomeStatus({
    required DocumentSnapshot? lastStatusDoc,
    required bool hasMoreStatuses,
  }) async {
    if (!hasMoreStatuses) {
      return (
      statuses: [],
      hasMore: false,
      lastDoc: lastStatusDoc,
      myStatuses: [],
      );
    }

    var friendsQuery = _repository.getFriendsForStatus(
      lastStatusDoc: lastStatusDoc,
      limit: 10,
    );

    final friendsSnapshot = await friendsQuery;
    final deletedStatusesSnapshot = await _repository.getDeletedStatuses();
    final deletedStatuses = deletedStatusesSnapshot.docs.postStatuses((doc) => doc.id).toList();

    if (friendsSnapshot.docs.isEmpty) {
      return (
      statuses: [],
      hasMore: false,
      lastDoc: lastStatusDoc,
      myStatuses: [],
      );
    }

    final newLastDoc = friendsSnapshot.docs.last;
    final friendsUIds = friendsSnapshot.docs.postStatuses((doc) => doc.id).toList();
    friendsUIds.add(UserDetails.uId);

    List<List<PostModel>> statusModelList = [];
    List<PostModel> myStatuses = [];

    for (final uId in friendsUIds) {
      try {
        final statusSnapshot = await _repository.getStatusesForUser(uId);
        if (statusSnapshot.docs.isEmpty) continue;

        final accountSnapshot = await _repository.getAccountData(
            statusSnapshot.docs.first['userId']
        );
        if (!accountSnapshot.exists) continue;

        final userAccount = await _repository.getAccountMap(accountSnapshot);
        List<PostModel> userStatuses = [];

        for (final statusDoc in statusSnapshot.docs) {
          if (deletedStatuses.contains(statusDoc.id)) continue;

          final statusData = {
            ...userAccount,
            ...statusDoc.data() as Map<String, dynamic>,/
          };

          userStatuses.add(PostModel.fromFirestoreToStatus(statusData));
        }

        if (userStatuses.isNotEmpty) {
          if (userStatuses.first.userId == UserDetails.uId) {
            myStatuses = userStatuses;
          } else {
            statusModelList.add(userStatuses);
          }
        }
      } catch (e) {
        continue;
      }
    }

    if (myStatuses.isNotEmpty) {
      statusModelList.insert(0, myStatuses);
    }
    statusModelList.sort((a, b) => b.first.dateTime!.compareTo(a.first.dateTime!));

    return (
    statuses: statusModelList,
    hasMore: statusModelList.isNotEmpty,
    lastDoc: newLastDoc,
    myStatuses: myStatuses,
    );
  }

  // إضافة بوست جديد
  Future<void> executeInsertPost(PostModel postModel) async {
    if (postModel.userId == null) {
      final userModel = await getUserAccountData();
      postModel
        ..userId = userModel.userId
        ..userName = userModel.userName
        ..userImage = userModel.userImage
        ..postType = postModel.postType ?? 'post';
    }
    await _repository.addPostToFirestore(postModel);
  }

  // إضافة status جديد
  Future<void> executeInsertStatus(PostModel statusModel) async {
    if (statusModel.userId == null) {
      final userModel = await getUserAccountData();
      statusModel
        ..userId = userModel.userId
        ..userName = userModel.userName
        ..userImage = userModel.userImage;
    }
    await _repository.addStatusToFirestore(statusModel);
  }

  // حذف بوست
  Future<void> executeDeletePost({
    required PostModel postModel,
    required bool isMyPost,
  }) async {
    if (!isMyPost) {
      await _repository.addToDeletedPosts(postModel.docId!);
    } else {
      await _repository.deletePostFromFirestore(postModel.docId!);
    }
  }

  // حذف status
  Future<void> executeDeleteStatus({
    required PostModel statusModel,
    required bool isMyStatus,
  }) async {
    if (!isMyStatus) {
      await _repository.addToDeletedStatuses(statusModel.docId!);
    } else {
      await _repository.deleteStatusFromFirestore(statusModel.docId!);
    }
  }

  // جلب بيانات المستخدم
  Future<void> executeGetUserAccount() async {
    final userModel = await getUserModelData(id: UserDetails.uId);
    UserDetails.name = userModel.userName!;
    UserDetails.image = userModel.userImage!;
  }

  // مراقبة الحالة online
  Stream<bool> executeGetUserOnlineStatus(
      OnlineStatusService onlineStatusService,
      String userId,
      ) {
    return onlineStatusService.getUserOnlineStatus(userId);
  }
}