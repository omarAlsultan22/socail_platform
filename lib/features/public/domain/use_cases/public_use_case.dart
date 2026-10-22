import 'dart:async';
import '../repositories/public_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:social_app/core/data/models/post_model.dart';
import 'package:social_app/core/data/models/paginated_posts.dart';
import 'package:social_app/core/services/data/session_service.dart';
import '../../../../core/services/domain/i_user_account_service.dart';
import '../../../../core/services/domain/i_online_status_service.dart';
import 'package:social_app/features/public/data/models/public_statuses.dart';


class PublicUseCase {
  final PublicRepository _repository;
  final SessionService _sessionService;
  final IUserAccountService _userAccountService;

  PublicUseCase({
    required PublicRepository repository,
    required SessionService sessionService,
    required IUserAccountService userAccountService,
  })
      : _repository = repository,
        _sessionService = sessionService,
        _userAccountService = userAccountService;

  Future<PaginatedPosts> executeGetHomePosts({
    required DocumentSnapshot? lastPostDoc,
    required bool hasMorePosts,
  }) async {
    if (!hasMorePosts) {
      return PaginatedPosts(
          dataList: [],
          hasMoreData: false,
          lastPostDoc: lastPostDoc
      );
    }

    final friendsSnapshot = await _repository.getFriendsList();
    final friendsUIds = friendsSnapshot.docs.map((doc) => doc.id)
        .toList();
    friendsUIds.add(_sessionService.currentUid);

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
    final deletedPosts = deletedPostsSnapshot.docs.map((doc) => doc.id)
        .toList();

    if (querySnapshot.docs.isEmpty) {
      return PaginatedPosts(
          dataList: [],
          hasMoreData: false,
          lastPostDoc: lastPostDoc
      );
    }

    final newLastDoc = querySnapshot.docs.last;
    final List<PostModel> posts = [];

    await Future.wait(querySnapshot.docs.map((doc) async {
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
          final friendAccountDoc = await _repository.getAccountData(
              data['friendId']);
          if (friendAccountDoc.exists) {
            friendAccount = await _repository.getAccountMap(friendAccountDoc);
          }
        }

        final counts = await _repository.getPostCounts(doc.id);
        final hasMeLiked = await _repository.hasMeLiked(doc.id);

        posts.add(
          PostModel.fromFirestoreToPost({
            ...userAccount,
            ...data,
            ...friendAccount,
            'docId': doc.id,
            'hasMeLiked': hasMeLiked,
            'likesNumber': counts.likesCount,
            'commentsNumber': counts.commentsCount,
          }),
        );
    }).toList());

    posts.sort((a, b) => b.myDateTime!.compareTo(a.myDateTime!));

    return PaginatedPosts(
      dataList: posts,
      lastPostDoc: newLastDoc,
      hasMoreData: posts.isNotEmpty,
    );
  }

  Future<PublicStatuses> executeGetHomeStatus({
    required DocumentSnapshot? lastStatusDoc,
    required bool hasMoreStatuses,
  }) async {
    if (!hasMoreStatuses) {
      return PublicStatuses(
        myStatuses: [],
        homeStatusesList: [],
        hasMoreStatuses: false,
        lastStatusDoc: lastStatusDoc,
      );
    }

    var friendsQuery = _repository.getFriendsForStatus(
      lastStatusDoc: lastStatusDoc,
      limit: 10,
    );

    final friendsSnapshot = await friendsQuery;
    final deletedStatusesSnapshot = await _repository.getDeletedStatuses();
    final deletedStatuses = deletedStatusesSnapshot.docs.map((doc) => doc.id)
        .toList();

    if (friendsSnapshot.docs.isEmpty) {
      return PublicStatuses(
        myStatuses: [],
        homeStatusesList: [],
        hasMoreStatuses: false,
        lastStatusDoc: lastStatusDoc,
      );
    }

    final newLastDoc = friendsSnapshot.docs.last;
    final friendsUIds = friendsSnapshot.docs.map((doc) => doc.id)
        .toList();
    friendsUIds.add(_sessionService.currentUid);

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
            ...statusDoc.data() as Map<String, dynamic>,
          };

          userStatuses.add(PostModel.fromFirestoreToStatus(statusData));
        }

        if (userStatuses.isNotEmpty) {
          if (userStatuses.first.myId == _sessionService.currentUid) {
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
    statusModelList.sort((a, b) =>
        b.first.myDateTime!.compareTo(a.first.myDateTime!));

    return PublicStatuses(
      myStatuses: myStatuses,
      lastStatusDoc: newLastDoc,
      homeStatusesList: statusModelList,
      hasMoreStatuses: statusModelList.isNotEmpty,
    );
  }

  Future<void> executeInsertPost(PostModel postModel) async {
    late PostModel newPostModel;
    if (!postModel.myIdIsEmpty) {
      final userModel = await _userAccountService.getUserAccountData();
      newPostModel = postModel.copyWith(
        myId: userModel.myId,
        postType: postModel.postType,

      );
    }
    await _repository.addPostToFirestore(newPostModel);
  }

  Future<void> executeDeletePost({
    required PostModel postModel,
    required bool isMyPost,
  }) async {
    if (!isMyPost) {
      await _repository.addToDeletedPosts(postModel.myDocId);
    } else {
      await _repository.deletePostFromFirestore(postModel.myDocId);
    }
  }

  Future<void> executeInsertStatus(PostModel statusModel) async {
    await _repository.addStatusToFirestore(statusModel);
  }

  Future<void> executeDeleteStatus({
    required PostModel statusModel,
    required bool isMyStatus,
  }) async {
    if (!isMyStatus) {
      await _repository.addToDeletedStatuses(statusModel.myDocId);
    } else {
      await _repository.deleteStatusFromFirestore(statusModel.myDocId);
    }
  }

  Stream<bool> executeGetUserOnlineStatus(
      IOnlineStatusService onlineStatusService,
      String userId,) {
    return onlineStatusService.getUserOnlineStatus(userId);
  }
}