import 'package:mocktail/mocktail.dart';
import 'package:flutter_test/flutter_test.dart';
import '../../../../fakes/mock_session_service.dart';
import '../../../../fakes/fake_public_repository.dart';
import '../../../../fakes/fake_user_account_service.dart';
import '../../../../fakes/mock_online_status_service.dart';
import 'package:social_app/core/constants/app_strings.dart';
import 'package:social_app/core/data/models/post_model.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:social_app/core/constants/firestore_schema.dart';
import 'package:social_app/features/public/domain/use_cases/public_use_case.dart';


void main() {
  late FakeFirebaseFirestore fakeFirestore;
  late FakePublicRepository fakeRepo;
  late MockSessionService mockSession;
  late FakeUserAccountService fakeAccountService;
  late PublicUseCase useCase;

  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
    fakeRepo = FakePublicRepository();
    mockSession = MockSessionService();
    fakeAccountService = FakeUserAccountService();
    when(() => mockSession.currentUid).thenReturn('uid-1');
    useCase = PublicUseCase(
      repository: fakeRepo,
      sessionService: mockSession,
      userAccountService: fakeAccountService,
    );
  });

  // ===== executeInsertStatus =====

  group('executeInsertStatus', () {
    test('calls addStatusToFirestore with statusModel', () async {
      final statusModel = PostModel(
        myId: 'uid-1',
        myDocId: 'status-1',
        userText: 'Status',
        myState: 'public',
        myDateTime: DateTime(2024, 5, 1),
      );

      await useCase.executeInsertStatus(statusModel);

      expect(fakeRepo.addStatusToFirestoreCallCount, 1);
      expect(fakeRepo.lastStatusModel, same(statusModel));
    });

    test('propagates errors from repository', () async {
      fakeRepo.addStatusToFirestoreError = Exception('save failed');
      final statusModel = PostModel(myId: 'uid-1', myDocId: 'status-1');

      expect(
            () => useCase.executeInsertStatus(statusModel),
        throwsA(isA<Exception>()),
      );
    });
  });

  // ===== executeDeletePost =====

  group('executeDeletePost', () {
    test('calls addToDeletedPosts when not my post', () async {
      final postModel = PostModel(myId: 'uid-1', myDocId: 'post-1');

      await useCase.executeDeletePost(
        postModel: postModel,
        isMyPost: false,
      );

      expect(fakeRepo.addToDeletedPostsCallCount, 1);
      expect(fakeRepo.lastDeletedPostId, 'post-1');
      expect(fakeRepo.deletePostFromFirestoreCallCount, 0);
    });

    test('calls deletePostFromFirestore when it is my post', () async {
      final postModel = PostModel(myId: 'uid-1', myDocId: 'post-1');

      await useCase.executeDeletePost(
        postModel: postModel,
        isMyPost: true,
      );

      expect(fakeRepo.deletePostFromFirestoreCallCount, 1);
      expect(fakeRepo.lastDeletedFromFirestorePostId, 'post-1');
      expect(fakeRepo.addToDeletedPostsCallCount, 0);
    });
  });

  // ===== executeDeleteStatus =====

  group('executeDeleteStatus', () {
    test('calls addToDeletedStatuses when not my status', () async {
      final statusModel = PostModel(myId: 'uid-1', myDocId: 'status-1');

      await useCase.executeDeleteStatus(
        statusModel: statusModel,
        isMyStatus: false,
      );

      expect(fakeRepo.addToDeletedStatusesCallCount, 1);
      expect(fakeRepo.lastDeletedStatusId, 'status-1');
      expect(fakeRepo.deleteStatusFromFirestoreCallCount, 0);
    });

    test('calls deleteStatusFromFirestore when it is my status', () async {
      final statusModel = PostModel(myId: 'uid-1', myDocId: 'status-1');

      await useCase.executeDeleteStatus(
        statusModel: statusModel,
        isMyStatus: true,
      );

      expect(fakeRepo.deleteStatusFromFirestoreCallCount, 1);
      expect(fakeRepo.lastDeletedFromFirestoreStatusId, 'status-1');
      expect(fakeRepo.addToDeletedStatusesCallCount, 0);
    });
  });

  // ===== executeGetUserOnlineStatus =====

  group('executeGetUserOnlineStatus', () {
    test('delegates to onlineStatusService.getUserOnlineStatus', () async {
      final mockOnlineStatus = MockOnlineStatusService();
      when(() => mockOnlineStatus.getUserOnlineStatus('user-1'))
          .thenAnswer((_) => Stream.value(true));

      final result = await useCase
          .executeGetUserOnlineStatus(mockOnlineStatus, 'user-1')
          .first;

      expect(result, true);
      verify(() => mockOnlineStatus.getUserOnlineStatus('user-1')).called(1);
    });

    test('emits false when user is offline', () async {
      final mockOnlineStatus = MockOnlineStatusService();
      when(() => mockOnlineStatus.getUserOnlineStatus('user-1'))
          .thenAnswer((_) => Stream.value(false));

      final result = await useCase
          .executeGetUserOnlineStatus(mockOnlineStatus, 'user-1')
          .first;

      expect(result, false);
    });
  });

  // ===== executeGetHomePosts — Simplified =====

  group('executeGetHomePosts', () {
    test('returns empty when hasMorePosts is false', () async {
      final result = await useCase.executeGetHomePosts(
        lastPostDoc: null,
        hasMorePosts: false,
      );

      expect(result.dataList, isEmpty);
      expect(result.hasMoreData, false);
      expect(fakeRepo.getFriendsListCallCount, 0);
    });

    test('returns empty when query has no documents', () async {
      // friends list
      final friendsSnapshot = await fakeFirestore
          .collection(FirestoreSchema.users)
          .doc('uid-1')
          .collection(FirestoreSchema.friends)
          .get();
      fakeRepo.friendsListResult = friendsSnapshot;

      // empty posts
      final postsSnapshot = await fakeFirestore.collection('posts').get();
      fakeRepo.postsQueryResult = postsSnapshot;

      // empty deleted posts
      final deletedSnapshot = await fakeFirestore
          .collection(FirestoreSchema.users)
          .doc('uid-1')
          .collection('deleted_posts')
          .get();
      fakeRepo.deletedPostsResult = deletedSnapshot;

      final result = await useCase.executeGetHomePosts(
        lastPostDoc: null,
        hasMorePosts: true,
      );

      expect(result.dataList, isEmpty);
      expect(result.hasMoreData, false);
    });

    test('includes currentUid in friendsUIds', () async {
      final friendsSnapshot = await fakeFirestore
          .collection(FirestoreSchema.users)
          .doc('uid-1')
          .collection(FirestoreSchema.friends)
          .get();
      fakeRepo.friendsListResult = friendsSnapshot;

      final postsSnapshot = await fakeFirestore.collection('posts').get();
      fakeRepo.postsQueryResult = postsSnapshot;

      final deletedSnapshot = await fakeFirestore
          .collection(FirestoreSchema.users)
          .doc('uid-1')
          .collection('deleted_posts')
          .get();
      fakeRepo.deletedPostsResult = deletedSnapshot;

      await useCase.executeGetHomePosts(
        lastPostDoc: null,
        hasMorePosts: true,
      );

      expect(fakeRepo.lastFriendsUIds, contains('uid-1'));
    });

    test('filters out deleted posts', () async {
      // friends
      final friendsSnapshot = await fakeFirestore
          .collection(FirestoreSchema.users)
          .doc('uid-1')
          .collection(FirestoreSchema.friends)
          .get();
      fakeRepo.friendsListResult = friendsSnapshot;

      // posts — 1 post
      await fakeFirestore.collection('posts').doc('post-1').set({
        AppStrings.userId: 'uid-1',
        AppStrings.userText: 'Hello',
        AppStrings.dateTime: DateTime(2024, 5, 1),
      });
      final postsSnapshot = await fakeFirestore.collection('posts').get();
      fakeRepo.postsQueryResult = postsSnapshot;

      // deleted — post-1
      await fakeFirestore
          .collection(FirestoreSchema.users)
          .doc('uid-1')
          .collection('deleted_posts')
          .doc('post-1')
          .set({});
      final deletedSnapshot = await fakeFirestore
          .collection(FirestoreSchema.users)
          .doc('uid-1')
          .collection('deleted_posts')
          .get();
      fakeRepo.deletedPostsResult = deletedSnapshot;

      final result = await useCase.executeGetHomePosts(
        lastPostDoc: null,
        hasMorePosts: true,
      );

      // post-1 deleted — لا يظهر
      expect(result.dataList, isEmpty);
    });
  });
}