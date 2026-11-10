import 'package:mocktail/mocktail.dart';
import 'package:flutter_test/flutter_test.dart';
import '../../../../fakes/mock_session_service.dart';
import 'package:social_app/core/constants/app_strings.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:social_app/core/constants/firestore_schema.dart';
import 'package:social_app/core/data/data_sources/remote/firestore/firestore_service_impl.dart';
import 'package:social_app/features/setup_friends/domain/repositories/setup_friends_repository.dart';
import 'package:social_app/features/setup_friends/data/repositories_impl/setup_friends_repository_impl.dart';


void main() {
  late FakeFirebaseFirestore fakeFirestore;
  late FirestoreServiceImpl dataSource;
  late MockSessionService mockSession;
  late SetupFriendsRepository repository;

  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
    dataSource = FirestoreServiceImpl(firestore: fakeFirestore);
    mockSession = MockSessionService();
    when(() => mockSession.currentUid).thenReturn('current-uid');
    repository = SetupFriendsRepositoryImpl(
      dataSource: dataSource,
      sessionService: mockSession,
    );
  });

  group('getSuggestsUsers', () {
    test('excludes current user from suggestions', () async {
      await fakeFirestore.collection(FirestoreSchema.users).doc('current-uid').set({});
      await fakeFirestore.collection(FirestoreSchema.users).doc('user-1').set({});

      await fakeFirestore.collection(FirestoreSchema.accounts).doc('current-uid').set({
        'myId': 'current-uid',
      });
      await fakeFirestore.collection(FirestoreSchema.accounts).doc('user-1').set({
        'myId': 'user-1',
      });

      final result = await repository.getSuggestsUsers();

      expect(result.length, 1);
      expect(result.first.myId, 'user-1');
    });

    test('excludes users without account document', () async {
      await fakeFirestore.collection(FirestoreSchema.users).doc('user-1').set({});
      await fakeFirestore.collection(FirestoreSchema.users).doc('user-2').set({});

      // user-1 له account، user-2 لا
      await fakeFirestore.collection(FirestoreSchema.accounts).doc('user-1').set({
        'myId': 'user-1',
      });

      final result = await repository.getSuggestsUsers();

      expect(result.length, 1);
      expect(result.first.myId, 'user-1');
    });

    test('returns empty list when no users', () async {
      final result = await repository.getSuggestsUsers();

      expect(result, isEmpty);
    });

    test('returns empty list when only current user exists', () async {
      await fakeFirestore.collection(FirestoreSchema.users).doc('current-uid').set({});
      await fakeFirestore.collection(FirestoreSchema.accounts).doc('current-uid').set({
        'myId': 'current-uid',
      });

      final result = await repository.getSuggestsUsers();

      expect(result, isEmpty);
    });
  });

  group('confirmNewFriend', () {
    test('adds friend in both directions', () async {
      await repository.confirmNewFriend(friendId: 'friend-uid');

      // current → friend
      final currentFriends = await fakeFirestore
          .collection(FirestoreSchema.users)
          .doc('current-uid')
          .collection(FirestoreSchema.friends)
          .get();
      expect(currentFriends.docs.length, 1);
      expect(currentFriends.docs.first.id, 'friend-uid');
      expect(currentFriends.docs.first.data()[AppStrings.uId], 'friend-uid');

      // friend → current
      final friendFriends = await fakeFirestore
          .collection(FirestoreSchema.users)
          .doc('friend-uid')
          .collection(FirestoreSchema.friends)
          .get();
      expect(friendFriends.docs.length, 1);
      expect(friendFriends.docs.first.id, 'current-uid');
      expect(friendFriends.docs.first.data()[AppStrings.uId], 'current-uid');
    });

    test('uses currentUid from SessionService', () async {
      when(() => mockSession.currentUid).thenReturn('custom-uid');

      await repository.confirmNewFriend(friendId: 'friend-uid');

      final customFriends = await fakeFirestore
          .collection(FirestoreSchema.users)
          .doc('custom-uid')
          .collection(FirestoreSchema.friends)
          .get();
      expect(customFriends.docs.length, 1);
    });
  });
}