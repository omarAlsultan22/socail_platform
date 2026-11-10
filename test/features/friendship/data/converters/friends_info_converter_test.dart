import 'package:mocktail/mocktail.dart';
import 'package:flutter_test/flutter_test.dart';
import '../../../../fakes/mock_session_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../fakes/fake_user_account_service.dart';
import 'package:social_app/core/data/models/my_model.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:social_app/features/friendship/data/converters/friends_info_converter.dart';


void main() {
  late FakeFirebaseFirestore fakeFirestore;
  late MockSessionService mockSession;
  late FakeUserAccountService fakeAccountService;

  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
    mockSession = MockSessionService();
    fakeAccountService = FakeUserAccountService();
    when(() => mockSession.currentUid).thenReturn('uid-1');
  });

  // helper — بناء QuerySnapshot فارغ
  Future<QuerySnapshot> emptySnapshot() async {
    return await fakeFirestore.collection('empty').get();
  }

  group('fromQuerySnapshotSuggests', () {
    test('returns empty list when suggests is empty', () async {
      final requests = await emptySnapshot();
      final friends = await emptySnapshot();
      final suggests = await emptySnapshot();

      final result = await FriendsInfoConverter.fromQuerySnapshotSuggests(
        requests,
        friends,
        suggests,
        sessionService: mockSession,
        userAccountService: fakeAccountService,
      );

      expect(result.data, isEmpty);
    });

    test('filters out current user', () async {
      // suggests: uid-1 (current), user-2
      await fakeFirestore.collection('users').doc('uid-1').set({});
      await fakeFirestore.collection('users').doc('user-2').set({});
      final suggests = await fakeFirestore.collection('users').get();

      final requests = await emptySnapshot();
      final friends = await emptySnapshot();

      fakeAccountService.getUserModelDataResult = MyModel(
        myId: 'user-2',
        myDateTime: DateTime(2024),
      );

      final result = await FriendsInfoConverter.fromQuerySnapshotSuggests(
        requests,
        friends,
        suggests,
        sessionService: mockSession,
        userAccountService: fakeAccountService,
      );

      // uid-1 — مستبعد (current)
      expect(result.data.length, 1);
      expect(result.data.first.myId, 'user-2');
      expect(fakeAccountService.getUserModelDataCallCount, 1);
    });

    test('filters out users in requests', () async {
      // suggests: user-1, user-2
      await fakeFirestore.collection('users').doc('user-1').set({});
      await fakeFirestore.collection('users').doc('user-2').set({});
      final suggests = await fakeFirestore.collection('users').get();

      // requests: user-1
      await fakeFirestore.collection('requests').doc('user-1').set({});
      final requests = await fakeFirestore.collection('requests').get();

      final friends = await emptySnapshot();

      fakeAccountService.getUserModelDataResult = MyModel(
        myId: 'user-2',
        myDateTime: DateTime(2024),
      );

      final result = await FriendsInfoConverter.fromQuerySnapshotSuggests(
        requests,
        friends,
        suggests,
        sessionService: mockSession,
        userAccountService: fakeAccountService,
      );

      // user-1 — مستبعد (في requests)
      expect(result.data.length, 1);
      expect(result.data.first.myId, 'user-2');
    });

    test('filters out users in friends', () async {
      // suggests: user-1, user-2
      await fakeFirestore.collection('users').doc('user-1').set({});
      await fakeFirestore.collection('users').doc('user-2').set({});
      final suggests = await fakeFirestore.collection('users').get();

      final requests = await emptySnapshot();

      // friends: user-1
      await fakeFirestore.collection('friends').doc('user-1').set({});
      final friends = await fakeFirestore.collection('friends').get();

      fakeAccountService.getUserModelDataResult = MyModel(
        myId: 'user-2',
        myDateTime: DateTime(2024),
      );

      final result = await FriendsInfoConverter.fromQuerySnapshotSuggests(
        requests,
        friends,
        suggests,
        sessionService: mockSession,
        userAccountService: fakeAccountService,
      );

      // user-1 — مستبعد (في friends)
      expect(result.data.length, 1);
      expect(result.data.first.myId, 'user-2');
    });

    test('returns all suggests when no filters match', () async {
      // suggests: user-1, user-2
      await fakeFirestore.collection('users').doc('user-1').set({});
      await fakeFirestore.collection('users').doc('user-2').set({});
      final suggests = await fakeFirestore.collection('users').get();

      final requests = await emptySnapshot();
      final friends = await emptySnapshot();

      fakeAccountService.getUserModelDataResult = MyModel(
        myId: 'user-1',
        myDateTime: DateTime(2024),
      );

      final result = await FriendsInfoConverter.fromQuerySnapshotSuggests(
        requests,
        friends,
        suggests,
        sessionService: mockSession,
        userAccountService: fakeAccountService,
      );

      expect(result.data.length, 2);
    });

    test('skips suggest on getUserModelData error', () async {
      // suggests: user-1, user-2
      await fakeFirestore.collection('users').doc('user-1').set({});
      await fakeFirestore.collection('users').doc('user-2').set({});
      final suggests = await fakeFirestore.collection('users').get();

      final requests = await emptySnapshot();
      final friends = await emptySnapshot();

      fakeAccountService.getUserModelDataError = Exception('user not found');

      final result = await FriendsInfoConverter.fromQuerySnapshotSuggests(
        requests,
        friends,
        suggests,
        sessionService: mockSession,
        userAccountService: fakeAccountService,
      );

      // كلاهما — خطأ — data فارغة
      expect(result.data, isEmpty);
    });

    test('uses updated currentUid', () async {
      when(() => mockSession.currentUid).thenReturn('custom-uid');

      // suggests: custom-uid, user-1
      await fakeFirestore.collection('users').doc('custom-uid').set({});
      await fakeFirestore.collection('users').doc('user-1').set({});
      final suggests = await fakeFirestore.collection('users').get();

      final requests = await emptySnapshot();
      final friends = await emptySnapshot();

      fakeAccountService.getUserModelDataResult = MyModel(
        myId: 'user-1',
        myDateTime: DateTime(2024),
      );

      final result = await FriendsInfoConverter.fromQuerySnapshotSuggests(
        requests,
        friends,
        suggests,
        sessionService: mockSession,
        userAccountService: fakeAccountService,
      );

      // custom-uid — مستبعد
      expect(result.data.length, 1);
      expect(result.data.first.myId, 'user-1');
    });

    test('does not call getUserModelData for filtered users', () async {
      // suggests: uid-1 (current), user-2 (in requests)
      await fakeFirestore.collection('users').doc('uid-1').set({});
      await fakeFirestore.collection('users').doc('user-2').set({});
      final suggests = await fakeFirestore.collection('users').get();

      await fakeFirestore.collection('requests').doc('user-2').set({});
      final requests = await fakeFirestore.collection('requests').get();

      final friends = await emptySnapshot();

      await FriendsInfoConverter.fromQuerySnapshotSuggests(
        requests,
        friends,
        suggests,
        sessionService: mockSession,
        userAccountService: fakeAccountService,
      );

      // getUserModelData — لم يُستدعَ (كلاهما مستبعد)
      expect(fakeAccountService.getUserModelDataCallCount, 0);
    });
  });
}