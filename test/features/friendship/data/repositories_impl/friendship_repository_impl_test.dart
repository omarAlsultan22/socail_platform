import 'package:flutter_test/flutter_test.dart';
import 'package:social_app/core/data/models/my_model.dart';
import 'package:social_app/core/constants/app_strings.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:social_app/core/constants/firestore_schema.dart';
import 'package:social_app/features/friendship/domain/repositories/friendship_repository.dart';
import 'package:social_app/core/data/data_sources/remote/firestore/firestore_service_impl.dart';
import 'package:social_app/features/friendship/data/repositories_impl/friendship_repository_impl.dart';


void main() {
  late FirestoreServiceImpl dataSource;
  late FriendshipRepository repository;
  late FakeFirebaseFirestore fakeFirestore;

  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
    dataSource = FirestoreServiceImpl(firestore: fakeFirestore);
    repository = FriendshipRepositoryImpl(dataSource: dataSource);
  });

  group('addFriendRequestToFirestore', () {
    test('adds friend request to users/{userId}/requests/{friendInfo.myId}',
            () async {
          final friendInfo = MyModel(
            myId: 'friend-1',
            myDateTime: DateTime(2024),
          );

          await repository.addFriendRequestToFirestore(
            userId: 'user-1',
            friendInfo: friendInfo,
          );

          final requestDoc = await fakeFirestore
              .collection(FirestoreSchema.users)
              .doc('user-1')
              .collection(FirestoreSchema.requests)
              .doc('friend-1')
              .get();

          expect(requestDoc.exists, true);
          expect(requestDoc.data()?['myId'], 'friend-1');
        });
  });

  group('confirmFriendInFirestore', () {
    test('adds friendship in both directions', () async {
      await repository.confirmFriendInFirestore(
        currentUserId: 'current-uid',
        friendId: 'friend-uid',
      );

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
  });

  group('getConversationsStream', () {
    test('emits MyModel list converted from requests', () async {
      // 2 requests
      await fakeFirestore
          .collection(FirestoreSchema.users)
          .doc('user-1')
          .collection(FirestoreSchema.requests)
          .doc('friend-1')
          .set({});
      await fakeFirestore
          .collection(FirestoreSchema.users)
          .doc('user-1')
          .collection(FirestoreSchema.requests)
          .doc('friend-2')
          .set({});

      final stream = repository.getConversationsStream(
        userId: 'user-1',
        getUserModelData: (id) async =>
            MyModel(
              myId: id,
              myDateTime: DateTime(2024),
            ),
      );

      final result = await stream.first;

      expect(result.length, 2);
      expect(result[0].myId, 'friend-1');
      expect(result[1].myId, 'friend-2');
    });

    test('emits empty list for no requests', () async {
      final stream = repository.getConversationsStream(
        userId: 'user-1',
        getUserModelData: (id) async =>
            MyModel(
              myId: id,
              myDateTime: DateTime(2024),
            ),
      );

      final result = await stream.first;

      expect(result, isEmpty);
    });
  });

  group('declineFriendRequestInFirestore', () {
    test('deletes users/{currentUid}/requests/{friendId}', () async {
      // نضع request
      await fakeFirestore
          .collection(FirestoreSchema.users)
          .doc('current-uid')
          .collection(FirestoreSchema.requests)
          .doc('friend-uid')
          .set({});

      await repository.declineFriendRequestInFirestore(
        currentUserId: 'current-uid',
        friendId: 'friend-uid',
      );

      final requestDoc = await fakeFirestore
          .collection(FirestoreSchema.users)
          .doc('current-uid')
          .collection(FirestoreSchema.requests)
          .doc('friend-uid')
          .get();
      expect(requestDoc.exists, false);
    });
  });

  group('getFriendsSuggestData', () {
    test('returns allUsers, friends, requests', () async {
      // 2 users
      await fakeFirestore.collection(FirestoreSchema.users).doc('user-1').set(
          {});
      await fakeFirestore.collection(FirestoreSchema.users).doc('user-2').set(
          {});

      // 1 friend for current
      await fakeFirestore
          .collection(FirestoreSchema.users)
          .doc('current-uid')
          .collection(FirestoreSchema.friends)
          .doc('friend-1')
          .set({});

      // 1 request for current
      await fakeFirestore
          .collection(FirestoreSchema.users)
          .doc('current-uid')
          .collection(FirestoreSchema.requests)
          .doc('requester-1')
          .set({});

      final result = await repository.getFriendsSuggestData(
        currentUserId: 'current-uid',
      );

      expect(result.allUsers.docs.length, 2);
      expect(result.friends.docs.length, 1);
      expect(result.requests.docs.length, 1);
    });

    test('returns empty snapshots when no data', () async {
      final result = await repository.getFriendsSuggestData(
        currentUserId: 'current-uid',
      );

      expect(result.allUsers.docs, isEmpty);
      expect(result.friends.docs, isEmpty);
      expect(result.requests.docs, isEmpty);
    });
  });
}