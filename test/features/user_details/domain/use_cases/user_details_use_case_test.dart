import 'package:mocktail/mocktail.dart';
import 'package:flutter_test/flutter_test.dart';
import '../../../../fakes/mock_session_service.dart';
import '../../../../fakes/fake_user_account_service.dart';
import 'package:social_app/core/data/models/my_model.dart';
import '../../../../fakes/fake_user_details_repository.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:social_app/core/constants/firestore_schema.dart';
import 'package:social_app/features/user_details/domain/use_cases/user_details_use_case.dart';


void main() {
  late FakeUserDetailsRepository fakeRepo;
  late FakeUserAccountService fakeAccountService;
  late MockSessionService mockSession;
  late UserDetailsUseCase useCase;
  late FakeFirebaseFirestore fakeFirestore;

  setUp(() {
    fakeRepo = FakeUserDetailsRepository();
    fakeAccountService = FakeUserAccountService();
    mockSession = MockSessionService();
    fakeFirestore = FakeFirebaseFirestore();
    when(() => mockSession.currentUid).thenReturn('uid-1');
    useCase = UserDetailsUseCase(
      repository: fakeRepo,
      sessionService: mockSession,
      userAccountService: fakeAccountService,
    );
  });

  group('executeGetUserDetails', () {
    test('uses uId when provided', () async {
      await fakeFirestore.collection('accounts').doc('uid-99').set({
        'userId': 'uid-99',
      });
      final doc = await fakeFirestore.collection('accounts')
          .doc('uid-99')
          .get();
      fakeRepo.myDetailsStream = Stream.value(doc);
      fakeAccountService.getAccountMapResult = {'userId': 'uid-99'};

      await useCase.executeGetUserDetails(uId: 'uid-99')!.first;

      expect(fakeRepo.lastMyDetailsDocId, 'uid-99');
      expect(fakeRepo.lastMyDetailsCollectionPath, FirestoreSchema.accounts);
    });

    test('uses currentUid when uId is null', () async {
      await fakeFirestore.collection('accounts').doc('uid-1').set({
        'userId': 'uid-1',
      });
      final doc = await fakeFirestore.collection('accounts').doc('uid-1').get();
      fakeRepo.myDetailsStream = Stream.value(doc);
      fakeAccountService.getAccountMapResult = {'userId': 'uid-1'};

      await useCase.executeGetUserDetails()!.first;

      expect(fakeRepo.lastMyDetailsDocId, 'uid-1');
    });

    test('calls getAccountMap and returns MyModel', () async {
      await fakeFirestore.collection('accounts').doc('uid-1').set({
        'userId': 'uid-1',
        'firstName': 'Ali',
      });
      final doc = await fakeFirestore.collection('accounts').doc('uid-1').get();
      fakeRepo.myDetailsStream = Stream.value(doc);
      fakeAccountService.getAccountMapResult =
      {'userId': 'uid-1', 'firstName': 'Ali'};

      final result = await useCase.executeGetUserDetails()!.first;

      expect(result, isA<MyModel>());
      expect(fakeAccountService.getAccountMapCallCount, 1);
    });
  });

  group('executeGetNotificationsStream', () {
    test('calls getFriendsList with currentUid', () async {
      final friendsSnapshot = await fakeFirestore
          .collection('users')
          .doc('uid-1')
          .collection('friends')
          .get();
      fakeRepo.friendsListStream = Stream.value(friendsSnapshot);

      await useCase
          .executeGetNotificationsStream()
          .first;

      expect(fakeRepo.getFriendsListCallCount, 1);
      expect(fakeRepo.lastFriendsListUid, 'uid-1');
    });

    test('includes currentUid in result even if not in friends', () async {
      // friendsSnapshot فارغة → friendsUIds = []
      // لكن currentUid يُضاف
      final friendsSnapshot = await fakeFirestore
          .collection('users')
          .doc('uid-1')
          .collection('friends')
          .get();
      fakeRepo.friendsListStream = Stream.value(friendsSnapshot);

      // نضع myDetailsStream — لأنه يُستدعى لكل uId
      await fakeFirestore.collection('accounts').doc('uid-1').set({
        'userId': 'uid-1',
      });
      final doc = await fakeFirestore.collection('accounts').doc('uid-1').get();
      fakeRepo.myDetailsStream = Stream.value(doc);
      fakeAccountService.getAccountMapResult = {'userId': 'uid-1'};

      final result = await useCase
          .executeGetNotificationsStream()
          .first;

      // currentUid موجود في النتيجة
      expect(result.containsKey('uid-1'), true);
    });

    test('does not duplicate currentUid if already in friends', () async {
      // friendsSnapshot تحتوي uid-1
      await fakeFirestore
          .collection('users')
          .doc('uid-1')
          .collection('friends')
          .doc('uid-1')
          .set({'name': 'Self'});

      final friendsSnapshot = await fakeFirestore
          .collection('users')
          .doc('uid-1')
          .collection('friends')
          .get();
      fakeRepo.friendsListStream = Stream.value(friendsSnapshot);

      await fakeFirestore.collection('accounts').doc('uid-1').set({
        'userId': 'uid-1',
      });
      final doc = await fakeFirestore.collection('accounts').doc('uid-1').get();
      fakeRepo.myDetailsStream = Stream.value(doc);
      fakeAccountService.getAccountMapResult = {'userId': 'uid-1'};

      final result = await useCase
          .executeGetNotificationsStream()
          .first;

      // uid-1 موجود مرة واحدة (لا تكرار)
      expect(result.keys
          .where((k) => k == 'uid-1')
          .length, 1);
    });

    test('creates stream for each friend', () async {
      // friendsSnapshot فيها friend-1, friend-2
      await fakeFirestore
          .collection('users')
          .doc('uid-1')
          .collection('friends')
          .doc('friend-1')
          .set({'name': 'A'});
      await fakeFirestore
          .collection('users')
          .doc('uid-1')
          .collection('friends')
          .doc('friend-2')
          .set({'name': 'B'});

      final friendsSnapshot = await fakeFirestore
          .collection('users')
          .doc('uid-1')
          .collection('friends')
          .get();
      fakeRepo.friendsListStream = Stream.value(friendsSnapshot);

      await fakeFirestore.collection('accounts').doc('uid-1').set(
          {'userId': 'uid-1'});
      await fakeFirestore.collection('accounts').doc('friend-1').set(
          {'userId': 'friend-1'});
      await fakeFirestore.collection('accounts').doc('friend-2').set(
          {'userId': 'friend-2'});

      final doc1 = await fakeFirestore.collection('accounts')
          .doc('uid-1')
          .get();
      fakeRepo.myDetailsStream = Stream.value(doc1);
      fakeAccountService.getAccountMapResult = {};

      final result = await useCase
          .executeGetNotificationsStream()
          .first;

      // 3 entries: uid-1, friend-1, friend-2
      expect(result.length, 3);
      expect(result.containsKey('uid-1'), true);
      expect(result.containsKey('friend-1'), true);
      expect(result.containsKey('friend-2'), true);
    });
  });
}