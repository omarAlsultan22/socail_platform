import 'package:flutter_test/flutter_test.dart';
import '../../../../fakes/fake_main_repository.dart';
import 'package:social_app/core/data/models/my_model.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:social_app/features/main/domain/use_cases/main_use_case.dart';


void main() {
  late FakeFirebaseFirestore fakeFirestore;
  late FakeMainRepository fakeRepo;
  late MainUseCases useCase;

  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
    fakeRepo = FakeMainRepository();
    useCase = MainUseCases(repository: fakeRepo);
  });

  group('executeCheckOnAnyFriends', () {
    test('returns empty list when friends exist', () async {
      // friends — 1 مستند
      await fakeFirestore.collection('users').doc('user-1').collection(
          'friends').doc('friend-1').set({});
      final friendsSnapshot = await fakeFirestore
          .collection('users')
          .doc('user-1')
          .collection('friends')
          .get();

      fakeRepo.friendsListResult = friendsSnapshot;

      final result = await useCase.executeCheckOnAnyFriends(uId: 'user-1');

      expect(result, isEmpty);
      // getAllUsersExceptCurrent — لم يُستدعَ
      expect(fakeRepo.getAllUsersExceptCurrentCallCount, 0);
    });

    test('returns users list when no friends', () async {
      // friends — فارغة
      final emptyFriends = await fakeFirestore
          .collection('users')
          .doc('user-1')
          .collection('friends')
          .get();
      fakeRepo.friendsListResult = emptyFriends;

      fakeRepo.convertUsersToModelsResult = [
        MyModel(myId: 'user-2', myDateTime: DateTime(2024)),
        MyModel(myId: 'user-3', myDateTime: DateTime(2024)),
      ];

      final result = await useCase.executeCheckOnAnyFriends(uId: 'user-1');

      expect(result.length, 2);
      expect(fakeRepo.getAllUsersExceptCurrentCallCount, 1);
      expect(fakeRepo.convertUsersToModelsCallCount, 1);
    });

    test('calls getFriendsList with uId', () async {
      final emptyFriends = await fakeFirestore
          .collection('users')
          .doc('user-1')
          .collection('friends')
          .get();
      fakeRepo.friendsListResult = emptyFriends;

      await useCase.executeCheckOnAnyFriends(uId: 'user-1');

      expect(fakeRepo.getFriendsListCallCount, 1);
    });
  });

  group('executeGetInitialNotificationsCount', () {
    test('returns count and docIds', () async {
      await fakeFirestore.collection('notifications').doc('n1').set(
          {'isRead': false});
      await fakeFirestore.collection('notifications').doc('n2').set(
          {'isRead': false});

      final snapshot = await fakeFirestore.collection('notifications').get();
      fakeRepo.unreadNotificationsResult = snapshot;

      final result = await useCase.executeGetInitialNotificationsCount();

      expect(result.count, 2);
      expect(result.docIds, {'n1', 'n2'});
    });

    test('returns 0 and empty set when no unread', () async {
      final emptySnapshot = await fakeFirestore.collection('notifications')
          .get();
      fakeRepo.unreadNotificationsResult = emptySnapshot;

      final result = await useCase.executeGetInitialNotificationsCount();

      expect(result.count, 0);
      expect(result.docIds, isEmpty);
    });
  });

  group('executeGetNotificationsStream', () {
    test('emits count, docIds, docs for each snapshot', () async {
      await fakeFirestore.collection('notifications').doc('n1').set(
          {'isRead': false});
      final snapshot = await fakeFirestore.collection('notifications').get();

      fakeRepo.notificationsStream = Stream.value(snapshot);

      final result = await useCase
          .executeGetNotificationsStream()
          .first;

      expect(result.count, 1);
      expect(result.docIds, {'n1'});
      expect(result.docs.length, 1);
    });

    test('emits empty for no notifications', () async {
      final emptySnapshot = await fakeFirestore.collection('notifications')
          .get();
      fakeRepo.notificationsStream = Stream.value(emptySnapshot);

      final result = await useCase
          .executeGetNotificationsStream()
          .first;

      expect(result.count, 0);
      expect(result.docIds, isEmpty);
      expect(result.docs, isEmpty);
    });
  });

  group('executeGetInitialFriendRequestsCount', () {
    test('returns count and docIds', () async {
      await fakeFirestore.collection('users').doc('uid-1').collection(
          'requests').doc('r1').set({});
      await fakeFirestore.collection('users').doc('uid-1').collection(
          'requests').doc('r2').set({});

      final snapshot = await fakeFirestore
          .collection('users')
          .doc('uid-1')
          .collection('requests')
          .get();
      fakeRepo.friendRequestsResult = snapshot;

      final result = await useCase.executeGetInitialFriendRequestsCount();

      expect(result.count, 2);
      expect(result.docIds, {'r1', 'r2'});
    });

    test('returns 0 and empty set when no requests', () async {
      final emptySnapshot = await fakeFirestore.collection('requests').get();
      fakeRepo.friendRequestsResult = emptySnapshot;

      final result = await useCase.executeGetInitialFriendRequestsCount();

      expect(result.count, 0);
      expect(result.docIds, isEmpty);
    });
  });

  group('executeGetFriendRequestsStream', () {
    test('emits count and docIds for each snapshot', () async {
      await fakeFirestore.collection('users').doc('uid-1').collection(
          'requests').doc('r1').set({});
      final snapshot = await fakeFirestore
          .collection('users')
          .doc('uid-1')
          .collection('requests')
          .get();

      fakeRepo.friendRequestsStream = Stream.value(snapshot);

      final result = await useCase
          .executeGetFriendRequestsStream()
          .first;

      expect(result.count, 1);
      expect(result.docIds, {'r1'});
    });

    test('emits empty for no requests', () async {
      final emptySnapshot = await fakeFirestore.collection('requests').get();
      fakeRepo.friendRequestsStream = Stream.value(emptySnapshot);

      final result = await useCase
          .executeGetFriendRequestsStream()
          .first;

      expect(result.count, 0);
      expect(result.docIds, isEmpty);
    });
  });
}