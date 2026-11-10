import 'package:mocktail/mocktail.dart';
import 'package:flutter_test/flutter_test.dart';
import '../../../../fakes/mock_session_service.dart';
import '../../../../fakes/fake_main_data_source.dart';
import 'package:social_app/core/data/models/my_model.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:social_app/core/constants/firestore_schema.dart';
import 'package:social_app/features/main/domain/repositories/main_repository.dart';
import 'package:social_app/features/main/data/repositories_impl/main_repository_impl.dart';


void main() {
  late FakeFirebaseFirestore fakeFirestore;
  late FakeMainDataSource fakeDataSource;
  late MockSessionService mockSession;
  late MainRepository repository;

  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
    fakeDataSource = FakeMainDataSource();
    mockSession = MockSessionService();
    when(() => mockSession.currentUid).thenReturn('uid-1');
    repository = MainRepositoryImpl(
      dataSource: fakeDataSource,
      sessionService: mockSession,
    );
  });

  group('getFriendsList', () {
    test('calls getSubCollection with users/{uId}/friends', () async {
      final emptySnapshot = await fakeFirestore.collection('users').get();
      fakeDataSource.subCollectionResult = emptySnapshot;

      await repository.getFriendsList(uId: 'user-1');

      expect(fakeDataSource.getSubCollectionCallCount, 1);
      expect(fakeDataSource.lastSubDocId, 'user-1');
      expect(fakeDataSource.lastSubSupCollectionPath, FirestoreSchema.users);
      expect(fakeDataSource.lastSubSubCollectionPath, FirestoreSchema.friends);
    });
  });

  group('getAllUsersExceptCurrent', () {
    test('delegates to dataSource.getAllUsersExceptCurrent', () async {
      final emptySnapshot = await fakeFirestore.collection('users').get();
      fakeDataSource.allUsersExceptCurrentResult = emptySnapshot;

      await repository.getAllUsersExceptCurrent(uId: 'user-1');

      expect(fakeDataSource.getAllUsersExceptCurrentCallCount, 1);
      expect(fakeDataSource.lastAllUsersUid, 'user-1');
    });
  });

  group('convertUsersToModels', () {
    test('converts snapshot docs to MyModel list', () async {
      await fakeFirestore.collection(FirestoreSchema.users).doc('1').set({
        'myId': '1',
        'myDateTime': DateTime(2024, 5, 1),
      });
      await fakeFirestore.collection(FirestoreSchema.users).doc('2').set({
        'myId': '2',
        'myDateTime': DateTime(2024, 5, 2),
      });

      final snapshot = await fakeFirestore.collection(FirestoreSchema.users).get();

      final result = repository.convertUsersToModels(snapshot);

      expect(result.length, 2);
      expect(result[0], isA<MyModel>());
      expect(result[1], isA<MyModel>());
    });

    test('returns empty list for empty snapshot', () async {
      final emptySnapshot = await fakeFirestore.collection(FirestoreSchema.users).get();

      final result = repository.convertUsersToModels(emptySnapshot);

      expect(result, isEmpty);
    });
  });

  group('getUnreadNotifications', () {
    test('delegates to dataSource.getUnreadNotifications', () async {
      final emptySnapshot = await fakeFirestore.collection('notifications').get();
      fakeDataSource.unreadNotificationsResult = emptySnapshot;

      await repository.getUnreadNotifications();

      expect(fakeDataSource.getUnreadNotificationsCallCount, 1);
    });
  });

  group('getNotificationsStream', () {
    test('delegates to dataSource.getNotificationsStream', () async {
      fakeDataSource.notificationsStream = const Stream.empty();

      repository.getNotificationsStream();

      expect(fakeDataSource.getNotificationsStreamCallCount, 1);
    });
  });

  group('getFriendRequests', () {
    test('calls getSubCollection with users/{currentUid}/requests', () async {
      final emptySnapshot = await fakeFirestore.collection('users').get();
      fakeDataSource.subCollectionResult = emptySnapshot;

      await repository.getFriendRequests();

      expect(fakeDataSource.getSubCollectionCallCount, 1);
      expect(fakeDataSource.lastSubDocId, 'uid-1');
      expect(fakeDataSource.lastSubSupCollectionPath, FirestoreSchema.users);
      expect(fakeDataSource.lastSubSubCollectionPath, FirestoreSchema.requests);
    });
  });

  group('getFriendRequestsStream', () {
    test('calls getSubCollectionStream with users/{currentUid}/requests',
            () async {
          fakeDataSource.subCollectionStream = const Stream.empty();

          repository.getFriendRequestsStream();

          expect(fakeDataSource.getSubCollectionStreamCallCount, 1);
          expect(fakeDataSource.lastSubStreamDocId, 'uid-1');
          expect(fakeDataSource.lastSubStreamSupCollectionPath, FirestoreSchema.users);
          expect(fakeDataSource.lastSubStreamSubCollectionPath, FirestoreSchema.requests);
        });
  });
}