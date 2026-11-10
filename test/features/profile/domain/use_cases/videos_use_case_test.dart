import 'package:flutter_test/flutter_test.dart';
import '../../../../fakes/fake_profile_repository.dart';
import 'package:social_app/core/constants/app_strings.dart';
import 'package:social_app/core/constants/app_constants.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:social_app/core/constants/firestore_schema.dart';
import 'package:social_app/features/profile/domain/use_cases/videos_use_case.dart';


void main() {
  late FakeFirebaseFirestore fakeFirestore;
  late FakeProfileRepository fakeRepo;
  late VideosUseCase useCase;

  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
    fakeRepo = FakeProfileRepository();
    useCase = VideosUseCase(repository: fakeRepo);
  });

  group('executeGetVideosPosts', () {
    test('returns empty PaginatedPosts when snapshot is empty', () async {
      final emptySnapshot = await fakeFirestore.collection('posts').get();
      fakeRepo.videosResult = emptySnapshot;

      final result = await useCase.executeGetVideosPosts('user-1', null);

      expect(result.dataList, isEmpty);
      expect(result.lastPostDoc, isNull);
      expect(result.hasMoreData, false);
    });

    test('calls getVideos with correct params', () async {
      final emptySnapshot = await fakeFirestore.collection('posts').get();
      fakeRepo.videosResult = emptySnapshot;

      await useCase.executeGetVideosPosts('user-1', null);

      expect(fakeRepo.getVideosCallCount, 1);
      expect(fakeRepo.lastVideosUserId, 'user-1');
      expect(fakeRepo.lastVideosLimit, AppConstants.limit);
      expect(fakeRepo.lastVideosLastDoc, isNull);
    });

    test('returns videos with hasMoreData false when less than limit',
            () async {
          // 2 videos
          await fakeFirestore.collection(FirestoreSchema.posts).doc('1').set({
            AppStrings.userId: 'user-1',
            AppStrings.userText: 'Video 1',
            AppStrings.dateTime: DateTime(2024, 5, 1),
          });
          await fakeFirestore.collection(FirestoreSchema.posts).doc('2').set({
            AppStrings.userId: 'user-1',
            AppStrings.userText: 'Video 2',
            AppStrings.dateTime: DateTime(2024, 5, 2),
          });

          final snapshot = await fakeFirestore.collection(FirestoreSchema.posts)
              .get();
          fakeRepo.videosResult = snapshot;
          fakeRepo.getAccountDataResult =
          {'userId': 'user-1', 'userName': 'Ali'};
          fakeRepo.postCountsResult = (comments: 1, likes: 2);
          fakeRepo.hasMeLikedResult = true;

          final result = await useCase.executeGetVideosPosts('user-1', null);

          expect(result.dataList.length, 2);
          expect(result.hasMoreData, false);
          expect(result.lastPostDoc, isNotNull);
        });

    test('calls getAccountData once (not per video)', () async {
      await fakeFirestore.collection(FirestoreSchema.posts).doc('1').set({
        AppStrings.userId: 'user-1',
        AppStrings.dateTime: DateTime(2024, 5, 1),
      });
      await fakeFirestore.collection(FirestoreSchema.posts).doc('2').set({
        AppStrings.userId: 'user-1',
        AppStrings.dateTime: DateTime(2024, 5, 2),
      });

      final snapshot = await fakeFirestore.collection(FirestoreSchema.posts)
          .get();
      fakeRepo.videosResult = snapshot;
      fakeRepo.getAccountDataResult = {'userId': 'user-1'};
      fakeRepo.postCountsResult = (comments: 0, likes: 0);

      await useCase.executeGetVideosPosts('user-1', null);

      // getAccountData — مرة واحدة (في بداية الدالة)
      expect(fakeRepo.getAccountDataCallCount, 1);
    });

    test('skips videos that throw errors (try/catch)', () async {
      await fakeFirestore.collection(FirestoreSchema.posts).doc('1').set({
        AppStrings.userId: 'user-1',
        AppStrings.dateTime: DateTime(2024, 5, 1),
      });

      final snapshot = await fakeFirestore.collection(FirestoreSchema.posts)
          .get();
      fakeRepo.videosResult = snapshot;
      fakeRepo.getAccountDataResult = {'userId': 'user-1'};
      fakeRepo.getAccountDataError = Exception('fetch failed');

      final result = await useCase.executeGetVideosPosts('user-1', null);

      // video مُتجاهل (try/catch → continue)
      expect(result.dataList, isEmpty);
    });

    test('sorts videos by dateTime descending', () async {
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

      final snapshot = await fakeFirestore.collection(FirestoreSchema.posts)
          .get();
      fakeRepo.videosResult = snapshot;
      fakeRepo.getAccountDataResult = {'userId': 'user-1'};
      fakeRepo.postCountsResult = (comments: 0, likes: 0);

      final result = await useCase.executeGetVideosPosts('user-1', null);

      expect(result.dataList.length, 3);
    });
  });
}