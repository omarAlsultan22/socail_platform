import 'package:mocktail/mocktail.dart';
import 'package:flutter_test/flutter_test.dart';
import '../../../../fakes/mock_session_service.dart';
import 'package:social_app/core/constants/app_strings.dart';
import '../../../../fakes/fake_post_detail_repository.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:social_app/core/constants/firestore_schema.dart';
import 'package:social_app/features/post_detail/data/models/post_detail_model.dart';
import 'package:social_app/features/post_detail/domain/use_cases/post_detail_use_case.dart';


void main() {
  late FakeFirebaseFirestore fakeFirestore;
  late FakePostDetailRepository fakeRepo;
  late MockSessionService mockSession;
  late PostDetailUseCase useCase;

  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
    fakeRepo = FakePostDetailRepository();
    mockSession = MockSessionService();
    when(() => mockSession.currentUid).thenReturn('uid-1');
    useCase = PostDetailUseCase(
      repository: fakeRepo,
      sessionService: mockSession,
    );
  });

  group('executeInsertNotification', () {
    test('builds MyModel and calls insertNotification', () async {
      await useCase.executeInsertNotification(
        userUid: 'uid-1',
        userImage: 'image.jpg',
        fullName: 'Ali Ahmed',
        userAction: 'like',
      );

      expect(fakeRepo.insertNotificationCallCount, 1);
      final notificationData = fakeRepo.lastNotificationData!;
      expect(notificationData.myId, 'uid-1');
      expect(notificationData.myName, 'Ali Ahmed');
      expect(notificationData.myImageUrl, 'image.jpg');
    });
  });

  group('executeGetPostData', () {
    test('throws when postDoc does not exist', () async {
      final missingPost = await fakeFirestore
          .collection(FirestoreSchema.posts)
          .doc('missing')
          .get();
      final userDoc = await fakeFirestore.collection(FirestoreSchema.accounts).doc('uid-1').get();
      final emptyComments = await fakeFirestore.collection('comments').get();

      fakeRepo.getPostDataResult = (
      postDoc: missingPost,
      userDoc: userDoc,
      commentsDocs: emptyComments,
      );

      expect(
            () => useCase.executeGetPostData(
          userId: 'uid-1',
          postId: 'missing',
        ),
        throwsA(isA<Exception>()),
      );
    });

    test('throws when userDoc does not exist', () async {
      await fakeFirestore.collection(FirestoreSchema.posts).doc('post-1').set({});
      final postDoc = await fakeFirestore.collection(FirestoreSchema.posts).doc('post-1').get();
      final missingUser = await fakeFirestore
          .collection(FirestoreSchema.accounts)
          .doc('missing')
          .get();
      final emptyComments = await fakeFirestore.collection('comments').get();

      fakeRepo.getPostDataResult = (
      postDoc: postDoc,
      userDoc: missingUser,
      commentsDocs: emptyComments,
      );

      expect(
            () => useCase.executeGetPostData(
          userId: 'missing',
          postId: 'post-1',
        ),
        throwsA(isA<Exception>()),
      );
    });

    test('returns PostDetailModel when post and user exist', () async {
      await fakeFirestore.collection(FirestoreSchema.posts).doc('post-1').set({
        AppStrings.userId: 'uid-1',
        AppStrings.userText: 'Hello',
        AppStrings.dateTime: DateTime(2024, 5, 1),
      });
      await fakeFirestore.collection(FirestoreSchema.accounts).doc('uid-1').set({
        AppStrings.userName: 'Ali',
        AppStrings.userImage: 'image.jpg',
      });
      final postDoc = await fakeFirestore.collection(FirestoreSchema.posts).doc('post-1').get();
      final userDoc = await fakeFirestore.collection(FirestoreSchema.accounts).doc('uid-1').get();
      final emptyComments = await fakeFirestore
          .collection(FirestoreSchema.posts)
          .doc('post-1')
          .collection(AppStrings.commentsList)
          .get();

      fakeRepo.getPostDataResult = (
      postDoc: postDoc,
      userDoc: userDoc,
      commentsDocs: emptyComments,
      );
      fakeRepo.hasMeLikedResult = true;
      fakeRepo.getPostLikesResult = 5;
      fakeRepo.getCommentsWithUsersResult = [];

      final result = await useCase.executeGetPostData(
        userId: 'uid-1',
        postId: 'post-1',
      );

      expect(result, isA<PostDetailModel>());
      expect(result.commentsList, isEmpty);
      expect(fakeRepo.hasMeLikedCallCount, 1);
      expect(fakeRepo.getPostLikesCallCount, 1);
      expect(fakeRepo.getCommentsWithUsersCallCount, 1);
    });

    test('passes commentsDocs and postId to getCommentsWithUsers', () async {
      await fakeFirestore.collection(FirestoreSchema.posts).doc('post-1').set({});
      await fakeFirestore.collection(FirestoreSchema.accounts).doc('uid-1').set({});
      final postDoc = await fakeFirestore.collection(FirestoreSchema.posts).doc('post-1').get();
      final userDoc = await fakeFirestore.collection(FirestoreSchema.accounts).doc('uid-1').get();
      final commentsSnapshot = await fakeFirestore
          .collection(FirestoreSchema.posts)
          .doc('post-1')
          .collection(AppStrings.commentsList)
          .get();

      fakeRepo.getPostDataResult = (
      postDoc: postDoc,
      userDoc: userDoc,
      commentsDocs: commentsSnapshot,
      );
      fakeRepo.getCommentsWithUsersResult = [];

      await useCase.executeGetPostData(
        userId: 'uid-1',
        postId: 'post-1',
      );

      expect(fakeRepo.getCommentsWithUsersCallCount, 1);
    });
  });

  group('_getAccountMap (via executeGetPostData)', () {
    test('returns map with userId, userName, userImage', () async {
      await fakeFirestore.collection(FirestoreSchema.posts).doc('post-1').set({
        AppStrings.userId: 'uid-1',
        AppStrings.dateTime: DateTime(2024, 5, 1),
      });
      await fakeFirestore.collection(FirestoreSchema.accounts).doc('uid-1').set({
        AppStrings.userName: 'Ali',
        AppStrings.userImage: 'url',
      });
      final postDoc = await fakeFirestore.collection(FirestoreSchema.posts).doc('post-1').get();
      final userDoc = await fakeFirestore.collection(FirestoreSchema.accounts).doc('uid-1').get();
      final emptyComments = await fakeFirestore
          .collection(FirestoreSchema.posts)
          .doc('post-1')
          .collection(AppStrings.commentsList)
          .get();

      fakeRepo.getPostDataResult = (
      postDoc: postDoc,
      userDoc: userDoc,
      commentsDocs: emptyComments,
      );

      await useCase.executeGetPostData(
        userId: 'uid-1',
        postId: 'post-1',
      );
    });
  });
}