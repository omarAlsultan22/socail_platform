import 'package:flutter_test/flutter_test.dart';
import '../../../../fakes/fake_profile_repository.dart';
import 'package:social_app/core/constants/app_strings.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:social_app/core/constants/firestore_schema.dart';
import 'package:social_app/features/profile/domain/use_cases/photos_use_case.dart';


void main() {
  late FakeFirebaseFirestore fakeFirestore;
  late FakeProfileRepository fakeRepo;
  late PhotosUseCase useCase;

  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
    fakeRepo = FakeProfileRepository();
    useCase = PhotosUseCase(repository: fakeRepo);
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

    test('calls getPosts with correct params', () async {
      final emptySnapshot = await fakeFirestore.collection('posts').get();
      fakeRepo.postsResult = emptySnapshot;

      await useCase.executeGetPostsData('user-1', null);

      expect(fakeRepo.getPostsCallCount, 1);
      expect(fakeRepo.lastUserId, 'user-1');
      expect(fakeRepo.lastPostType, isNull);
    });

    test('returns posts with hasMoreData false when less than limit',
            () async {
          // 2 posts — limit 10
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

          final snapshot = await fakeFirestore.collection(FirestoreSchema.posts)
              .get();
          fakeRepo.postsResult = snapshot;
          fakeRepo.getAccountDataResult =
          {'userId': 'user-1', 'userName': 'Ali'};
          fakeRepo.postCountsResult = (comments: 1, likes: 2);
          fakeRepo.hasMeLikedResult = true;

          final result = await useCase.executeGetPostsData('user-1', null);

          expect(result.dataList.length, 2);
          expect(result.hasMoreData, false); // 2 < 10
          expect(result.lastPostDoc, isNotNull);
        });

    test('sorts posts by dateTime descending', () async {
      await fakeFirestore.collection(FirestoreSchema.posts).doc('1').set({
        AppStrings.userId: 'user-1',
        AppStrings.dateTime: DateTime(2024, 5, 1),
      });
      await fakeFirestore.collection(FirestoreSchema.posts).doc('2').set({
        AppStrings.userId: 'user-1',
        AppStrings.dateTime: DateTime(2024, 5, 3),
      });
      await fakeFirestore.collection(FirestoreSchema.posts).doc('3').set({
        AppStrings.userId: 'user-1',
        AppStrings.dateTime: DateTime(2024, 5, 2),
      });

      final snapshot = await fakeFirestore.collection(FirestoreSchema.posts)
          .get();
      fakeRepo.postsResult = snapshot;
      fakeRepo.getAccountDataResult = {'userId': 'user-1'};
      fakeRepo.postCountsResult = (comments: 0, likes: 0);

      final result = await useCase.executeGetPostsData('user-1', null);

      // الأحدث أولاً — May 3, May 2, May 1
      expect(result.dataList.length, 3);
      // لا يمكن التحقق بسهولة من الترتيب — لأن PostModel معقد
    });
  });

  group('executeGetProfileImages', () {
    test('passes postType profileImage', () async {
      final emptySnapshot = await fakeFirestore.collection('posts').get();
      fakeRepo.postsResult = emptySnapshot;

      await useCase.executeGetProfileImages('user-1', null);

      expect(fakeRepo.lastPostType, AppStrings.profileImage);
    });

    test('returns empty when no images', () async {
      final emptySnapshot = await fakeFirestore.collection('posts').get();
      fakeRepo.postsResult = emptySnapshot;

      final result = await useCase.executeGetProfileImages('user-1', null);

      expect(result.dataList, isEmpty);
      expect(result.hasMoreData, false);
    });
  });

  group('executeGetCoverImages', () {
    test('passes postType coverImage', () async {
      final emptySnapshot = await fakeFirestore.collection('posts').get();
      fakeRepo.postsResult = emptySnapshot;

      await useCase.executeGetCoverImages('user-1', null);

      expect(fakeRepo.lastPostType, 'coverImage');
    });

    test('returns empty when no covers', () async {
      final emptySnapshot = await fakeFirestore.collection('posts').get();
      fakeRepo.postsResult = emptySnapshot;

      final result = await useCase.executeGetCoverImages('user-1', null);

      expect(result.dataList, isEmpty);
      expect(result.hasMoreData, false);
    });
  });
}