import 'package:flutter_test/flutter_test.dart';
import '../../../../fakes/fake_profile_repository.dart';
import 'package:social_app/core/data/models/my_model.dart';
import 'package:social_app/core/constants/app_strings.dart';
import 'package:social_app/core/constants/app_constants.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:social_app/core/constants/firestore_schema.dart';
import 'package:social_app/features/profile/domain/use_cases/posts_use_case.dart';


void main() {
  late FakeFirebaseFirestore fakeFirestore;
  late FakeProfileRepository fakeRepo;
  late PostsUseCase useCase;

  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
    fakeRepo = FakeProfileRepository();
    useCase = PostsUseCase(repository: fakeRepo);
  });

  group('executeGetPostsData', () {
    test('returns empty PaginatedPosts when snapshot is empty', () async {
      final emptySnapshot = await fakeFirestore.collection('posts').get();
      fakeRepo.postsResult = emptySnapshot;

      final result = await useCase.executeGetPostsData('user-1', null);

      expect(result.dataList, isEmpty);
      expect(result.lastPostDoc, isNull);
      expect(result.hasMoreData, false);
    });

    test('passes postType post and limit to repository', () async {
      final emptySnapshot = await fakeFirestore.collection('posts').get();
      fakeRepo.postsResult = emptySnapshot;

      await useCase.executeGetPostsData('user-1', null);

      expect(fakeRepo.getPostsCallCount, 1);
      expect(fakeRepo.lastUserId, 'user-1');
      expect(fakeRepo.lastPostType, AppStrings.post);
      expect(fakeRepo.lastLimit, AppConstants.limit);
    });

    test('returns posts with hasMoreData false when less than limit',
            () async {
          // 2 posts — limit > 2
          await fakeFirestore.collection(FirestoreSchema.posts).doc('1').set({
            AppStrings.userId: 'user-1',
            AppStrings.userText: 'Post 1',
            AppStrings.dateTime: DateTime(2024, 5, 1),
          });
          await fakeFirestore.collection(FirestoreSchema.posts).doc('2').set({
            AppStrings.userId: 'user-1',
            AppStrings.userText: 'Post 2',
            AppStrings.dateTime: DateTime(2024, 5, 2),
          });

          final snapshot = await fakeFirestore.collection(FirestoreSchema.posts).get();
          fakeRepo.postsResult = snapshot;
          fakeRepo.getAccountDataResult = {'userId': 'user-1', 'userName': 'Ali'};
          fakeRepo.postCountsResult = (comments: 1, likes: 2);
          fakeRepo.hasMeLikedResult = true;

          final result = await useCase.executeGetPostsData('user-1', null);

          expect(result.dataList.length, 2);
          expect(result.hasMoreData, false);
          expect(result.lastPostDoc, isNotNull);
        });

    test('calls getAccountData for friend when isActive', () async {
      await fakeFirestore.collection(FirestoreSchema.posts).doc('1').set({
        AppStrings.userId: 'user-1',
        AppStrings.friendId: 'friend-1',
        AppStrings.dateTime: DateTime(2024, 5, 1),
      });

      final snapshot = await fakeFirestore.collection(FirestoreSchema.posts).get();
      fakeRepo.postsResult = snapshot;
      fakeRepo.getAccountDataResult = {'userId': 'user-1'};
      fakeRepo.postCountsResult = (comments: 0, likes: 0);

      await useCase.executeGetPostsData('user-1', null);

      expect(fakeRepo.getAccountDataCallCount, 2);
      // آخر userId — friend-1 (لأن friend يُستدعى بعد user)
      expect(fakeRepo.lastGetAccountDataUserId, 'friend-1');
    });

    test('calls getAccountData once when not isActive', () async {
      await fakeFirestore.collection(FirestoreSchema.posts).doc('1').set({
        AppStrings.userId: 'user-1',
        AppStrings.dateTime: DateTime(2024, 5, 1),
      });

      final snapshot = await fakeFirestore.collection(FirestoreSchema.posts).get();
      fakeRepo.postsResult = snapshot;
      fakeRepo.getAccountDataResult = {'userId': 'user-1'};
      fakeRepo.postCountsResult = (comments: 0, likes: 0);

      await useCase.executeGetPostsData('user-1', null);

      expect(fakeRepo.getAccountDataCallCount, 1);
    });

    test('skips posts that throw errors (try/catch)', () async {
      await fakeFirestore.collection(FirestoreSchema.posts).doc('1').set({
        AppStrings.userId: 'user-1',
        AppStrings.dateTime: DateTime(2024, 5, 1),
      });

      final snapshot = await fakeFirestore.collection(FirestoreSchema.posts).get();
      fakeRepo.postsResult = snapshot;
      fakeRepo.getAccountDataError = Exception('fetch failed');

      final result = await useCase.executeGetPostsData('user-1', null);

      // post مُتجاهل (try/catch → continue)
      expect(result.dataList, isEmpty);
      expect(result.hasMoreData, false);
    });

    test('processes multiple posts and sorts by dateTime descending',
            () async {
          await fakeFirestore.collection(FirestoreSchema.posts).doc('1').set({
            AppStrings.userId: 'user-1',
            AppStrings.userText: 'Old',
            AppStrings.dateTime: DateTime(2024, 5, 1),
          });
          await fakeFirestore.collection(FirestoreSchema.posts).doc('2').set({
            AppStrings.userId: 'user-1',
            AppStrings.userText: 'New',
            AppStrings.dateTime: DateTime(2024, 5, 3),
          });
          await fakeFirestore.collection(FirestoreSchema.posts).doc('3').set({
            AppStrings.userId: 'user-1',
            AppStrings.userText: 'Mid',
            AppStrings.dateTime: DateTime(2024, 5, 2),
          });

          final snapshot = await fakeFirestore.collection(FirestoreSchema.posts).get();
          fakeRepo.postsResult = snapshot;
          fakeRepo.getAccountDataResult = {'userId': 'user-1'};
          fakeRepo.postCountsResult = (comments: 0, likes: 0);

          final result = await useCase.executeGetPostsData('user-1', null);

          expect(result.dataList.length, 3);
        });
  });

  group('executeGetFriends', () {
    test('returns list from repository', () async {
      final expected = [
        MyModel(myId: 'friend-1', myDateTime: DateTime(2024)),
        MyModel(myId: 'friend-2', myDateTime: DateTime(2024)),
      ];
      fakeRepo.getFriendsResult = expected;

      final result = await useCase.executeGetFriends('user-1');

      expect(result, same(expected));
      expect(fakeRepo.getFriendsCallCount, 1);
      expect(fakeRepo.lastGetFriendsUserId, 'user-1');
    });

    test('returns empty list when no friends', () async {
      fakeRepo.getFriendsResult = [];

      final result = await useCase.executeGetFriends('user-1');

      expect(result, isEmpty);
    });

    test('propagates errors from repository', () async {
      fakeRepo.getFriendsError = Exception('fetch failed');

      expect(
            () => useCase.executeGetFriends('user-1'),
        throwsA(isA<Exception>()),
      );
    });
  });
}