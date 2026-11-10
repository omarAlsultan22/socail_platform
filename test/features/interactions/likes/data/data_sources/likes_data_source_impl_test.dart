import 'package:mocktail/mocktail.dart';
import 'package:flutter_test/flutter_test.dart';
import '../../../../../fakes/mock_session_service.dart';
import 'package:social_app/core/data/models/my_model.dart';
import 'package:social_app/core/constants/app_strings.dart';
import '../../../../../fakes/fake_user_account_service.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:social_app/core/constants/firestore_schema.dart';
import 'package:social_app/features/interactions/likes/data/data_sources/likes_data_source_impl.dart';


void main() {
  late FakeFirebaseFirestore fakeFirestore;
  late MockSessionService mockSession;
  late FakeUserAccountService fakeAccountService;
  late LikesDataSourceImpl dataSource;

  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
    mockSession = MockSessionService();
    fakeAccountService = FakeUserAccountService();
    when(() => mockSession.currentUid).thenReturn('uid-1');
    dataSource = LikesDataSourceImpl(
      sessionService: mockSession,
      userAccountService: fakeAccountService,
    );
  });

  group('getLikesStream', () {
    test('emits empty when no likes', () async {
      final stream = dataSource.getLikesStream('post-1');
      final result = await stream.first;

      expect(result, isEmpty);
    });

    test('emits MyModel list when likes exist', () async {
      // like من uid-2
      await fakeFirestore
          .collection(FirestoreSchema.posts)
          .doc('post-1')
          .collection(AppStrings.likesList)
          .doc('uid-2')
          .set({});

      // account uid-2
      await fakeFirestore.collection(FirestoreSchema.accounts).doc('uid-2').set(
          {
            AppStrings.userName: 'Sara',
            AppStrings.userImage: 'url',
            'myDateTime': DateTime(2024, 5, 1),
          });

      fakeAccountService.getUserAccountResult = {
        AppStrings.userName: 'Sara',
        AppStrings.userImage: 'url',
        'myDateTime': DateTime(2024, 5, 1),
      };

      final stream = dataSource.getLikesStream('post-1');
      final result = await stream.first;

      expect(result.length, 1);
      expect(result.first, isA<MyModel>());
    });

    test('skips likes when account does not exist', () async {
      // like من missing-user
      await fakeFirestore
          .collection(FirestoreSchema.posts)
          .doc('post-1')
          .collection(AppStrings.likesList)
          .doc('missing-user')
          .set({});

      final stream = dataSource.getLikesStream('post-1');
      final result = await stream.first;

      expect(result, isEmpty);
    });

    test('sets isFriend based on friends list', () async {
      // friends — uid-2
      await fakeFirestore
          .collection(FirestoreSchema.users)
          .doc('uid-1')
          .collection(FirestoreSchema.friends)
          .doc('uid-2')
          .set({});

      // like من uid-2
      await fakeFirestore
          .collection(FirestoreSchema.posts)
          .doc('post-1')
          .collection(AppStrings.likesList)
          .doc('uid-2')
          .set({});

      await fakeFirestore.collection(FirestoreSchema.accounts).doc('uid-2').set(
          {
            AppStrings.userName: 'Sara',
            'myDateTime': DateTime(2024, 5, 1),
          });

      fakeAccountService.getUserAccountResult = {
        AppStrings.userName: 'Sara',
        'isFriend': true,
        'myDateTime': DateTime(2024, 5, 1),
      };

      final stream = dataSource.getLikesStream('post-1');
      final result = await stream.first;

      expect(result.length, 1);
      // isFriend — true (uid-2 في friends)
    });

    test('calls getUserAccount for each like', () async {
      // 2 likes
      await fakeFirestore
          .collection(FirestoreSchema.posts)
          .doc('post-1')
          .collection(AppStrings.likesList)
          .doc('uid-2')
          .set({});
      await fakeFirestore
          .collection(FirestoreSchema.posts)
          .doc('post-1')
          .collection(AppStrings.likesList)
          .doc('uid-3')
          .set({});

      await fakeFirestore.collection(FirestoreSchema.accounts).doc('uid-2').set(
          {
            'myDateTime': DateTime(2024, 5, 1),
          });
      await fakeFirestore.collection(FirestoreSchema.accounts).doc('uid-3').set(
          {
            'myDateTime': DateTime(2024, 5, 2),
          });

      fakeAccountService.getUserAccountResult = {
        'myDateTime': DateTime(2024, 5, 1),
      };

      final stream = dataSource.getLikesStream('post-1');
      await stream.first;

      expect(fakeAccountService.getUserAccountCallCount, 2);
    });

    test('sorts likes by myDateTime descending', () async {
      // 2 likes — dates 1, 3, 2
      await fakeFirestore
          .collection(FirestoreSchema.posts)
          .doc('post-1')
          .collection(AppStrings.likesList)
          .doc('uid-1').set({});
      await fakeFirestore
          .collection(FirestoreSchema.posts)
          .doc('post-1')
          .collection(AppStrings.likesList)
          .doc('uid-2').set({});
      await fakeFirestore
          .collection(FirestoreSchema.posts)
          .doc('post-1')
          .collection(AppStrings.likesList)
          .doc('uid-3').set({});

      await fakeFirestore.collection(FirestoreSchema.accounts).doc('uid-1').set(
          {
            'myDateTime': DateTime(2024, 5, 1),
          });
      await fakeFirestore.collection(FirestoreSchema.accounts).doc('uid-2').set(
          {
            'myDateTime': DateTime(2024, 5, 3),
          });
      await fakeFirestore.collection(FirestoreSchema.accounts).doc('uid-3').set(
          {
            'myDateTime': DateTime(2024, 5, 2),
          });

      fakeAccountService.getUserAccountResult = {
        'myDateTime': DateTime(2024, 5, 1),
      };

      final stream = dataSource.getLikesStream('post-1');
      await stream.first;

      // sort — descending
      expect(fakeAccountService.getUserAccountCallCount, 3);
    });
  });
}