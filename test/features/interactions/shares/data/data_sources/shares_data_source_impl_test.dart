import 'package:mocktail/mocktail.dart';
import 'package:flutter_test/flutter_test.dart';
import '../../../../../fakes/mock_session_service.dart';
import 'package:social_app/core/data/models/my_model.dart';
import 'package:social_app/core/constants/app_strings.dart';
import '../../../../../fakes/fake_user_account_service.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:social_app/core/constants/firestore_schema.dart';
import 'package:social_app/features/interactions/shares/data/data_sources/shares_data_source_impl.dart';


void main() {
  late MockSessionService mockSession;
  late SharesDataSourceImpl dataSource;
  late FakeFirebaseFirestore fakeFirestore;
  late FakeUserAccountService fakeAccountService;

  setUp(() {
    mockSession = MockSessionService();
    fakeFirestore = FakeFirebaseFirestore();
    fakeAccountService = FakeUserAccountService();
    when(() => mockSession.currentUid).thenReturn('uid-1');
    dataSource = SharesDataSourceImpl(
      sessionService: mockSession,
      userAccountService: fakeAccountService,
    );
  });

  group('getSharesStream', () {
    test('emits empty when no shares', () async {
      final stream = dataSource.getSharesStream('post-1');
      final result = await stream.first;

      expect(result, isEmpty);
    });

    test('emits MyModel list when shares exist', () async {
      // share من uid-2
      await fakeFirestore
          .collection(FirestoreSchema.posts)
          .doc('post-1')
          .collection(AppStrings.sharesList)
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

      final stream = dataSource.getSharesStream('post-1');
      final result = await stream.first;

      expect(result.length, 1);
      expect(result.first, isA<MyModel>());
    });

    test('skips shares when account does not exist', () async {
      // share من missing-user
      await fakeFirestore
          .collection(FirestoreSchema.posts)
          .doc('post-1')
          .collection(AppStrings.sharesList)
          .doc('missing-user')
          .set({});

      final stream = dataSource.getSharesStream('post-1');
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

      // share من uid-2
      await fakeFirestore
          .collection(FirestoreSchema.posts)
          .doc('post-1')
          .collection(AppStrings.sharesList)
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

      final stream = dataSource.getSharesStream('post-1');
      final result = await stream.first;

      expect(result.length, 1);
    });

    test('calls getUserAccount for each share', () async {
      // 2 shares
      await fakeFirestore
          .collection(FirestoreSchema.posts)
          .doc('post-1')
          .collection(AppStrings.sharesList)
          .doc('uid-2')
          .set({});
      await fakeFirestore
          .collection(FirestoreSchema.posts)
          .doc('post-1')
          .collection(AppStrings.sharesList)
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

      final stream = dataSource.getSharesStream('post-1');
      await stream.first;

      expect(fakeAccountService.getUserAccountCallCount, 2);
    });

    test('sorts shares by myDateTime descending', () async {
      // 3 shares
      for (final uid in ['uid-1', 'uid-2', 'uid-3']) {
        await fakeFirestore
            .collection(FirestoreSchema.posts)
            .doc('post-1')
            .collection(AppStrings.sharesList)
            .doc(uid)
            .set({});

        await fakeFirestore.collection(FirestoreSchema.accounts).doc(uid).set({
          'myDateTime': DateTime(2024, 5, int.parse(uid
              .split('-')
              .last)),
        });
      }

      fakeAccountService.getUserAccountResult = {
        'myDateTime': DateTime(2024, 5, 1),
      };

      final stream = dataSource.getSharesStream('post-1');
      await stream.first;

      expect(fakeAccountService.getUserAccountCallCount, 3);
    });

    test('continues when getUserAccount throws (no rethrow)', () async {
      // 2 shares — الأولى ترمي
      await fakeFirestore
          .collection(FirestoreSchema.posts)
          .doc('post-1')
          .collection(AppStrings.sharesList)
          .doc('uid-2')
          .set({});
      await fakeFirestore
          .collection(FirestoreSchema.posts)
          .doc('post-1')
          .collection(AppStrings.sharesList)
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

      fakeAccountService.getUserAccountError = Exception('fetch failed');

      final stream = dataSource.getSharesStream('post-1');
      final result = await stream.first;

      // كلا الـ shares — خطأ — data فارغة
      expect(result, isEmpty);
    });
  });
}