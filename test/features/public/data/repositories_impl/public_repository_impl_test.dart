import 'package:mocktail/mocktail.dart';
import 'package:flutter_test/flutter_test.dart';
import '../../../../fakes/mock_session_service.dart';
import '../../../../fakes/fake_public_data_source.dart';
import 'package:social_app/core/data/models/post_model.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:social_app/core/constants/firestore_schema.dart';
import 'package:social_app/features/public/constants/public_constants.dart';
import 'package:social_app/features/public/domain/repositories/public_repository.dart';
import 'package:social_app/features/public/data/repositories_impl/public_repository_impl.dart';


void main() {
  late FakeFirebaseFirestore fakeFirestore;
  late FakePublicDataSource fakeDataSource;
  late MockSessionService mockSession;
  late PublicRepository repository;

  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
    fakeDataSource = FakePublicDataSource();
    mockSession = MockSessionService();
    when(() => mockSession.currentUid).thenReturn('uid-1');
    repository = PublicRepositoryImpl(
      dataSource: fakeDataSource,
      sessionService: mockSession,
    );
  });

  group('getFriendsList', () {
    test('calls getSubCollection with users/friends and currentUid', () async {
      await fakeFirestore
          .collection(FirestoreSchema.users)
          .doc('uid-1')
          .collection(FirestoreSchema.friends)
          .doc('friend-1')
          .set({});
      final snapshot = await fakeFirestore
          .collection(FirestoreSchema.users)
          .doc('uid-1')
          .collection(FirestoreSchema.friends)
          .get();
      fakeDataSource.subCollectionResult = snapshot;

      await repository.getFriendsList();

      expect(fakeDataSource.getSubCollectionCallCount, 1);
      expect(fakeDataSource.lastSubDocId, 'uid-1');
      expect(fakeDataSource.lastSubSupCollectionPath, FirestoreSchema.users);
      expect(fakeDataSource.lastSubSubCollectionPath, FirestoreSchema.friends);
    });
  });

  group('fetchPostsQuery', () {
    test('delegates to dataSource.getDocumentsWithWhereIn', () async {
      final snapshot = await fakeFirestore.collection('posts').get();
      fakeDataSource.documentsWithWhereInResult = snapshot;
      final lastDoc = await fakeFirestore.collection('x').doc('d1').get();

      await repository.fetchPostsQuery(
        friendsUIds: ['f1', 'f2'],
        lastPostDoc: lastDoc,
        limit: 10,
      );

      expect(fakeDataSource.getDocumentsWithWhereInCallCount, 1);
      expect(fakeDataSource.lastFriendsUIds, ['f1', 'f2']);
      expect(fakeDataSource.lastLastPostDoc, same(lastDoc));
      expect(fakeDataSource.lastLimit, 10);
    });
  });

  group('getDeletedPosts', () {
    test('calls getSubCollection with users/{uid}/deleted_posts', () async {
      final snapshot = await fakeFirestore
          .collection(FirestoreSchema.users)
          .doc('uid-1')
          .collection('deleted_posts')
          .get();
      fakeDataSource.subCollectionResult = snapshot;

      await repository.getDeletedPosts();

      expect(fakeDataSource.lastSubDocId, 'uid-1');
      expect(fakeDataSource.lastSubSupCollectionPath, FirestoreSchema.users);
      expect(fakeDataSource.lastSubSubCollectionPath, 'deleted_posts');
    });
  });

  group('getAccountData', () {
    test('calls getDoc with accounts and userId', () async {
      await fakeFirestore
          .collection(FirestoreSchema.accounts)
          .doc('user-1')
          .set({'name': 'Ali'});
      final doc = await fakeFirestore
          .collection(FirestoreSchema.accounts)
          .doc('user-1')
          .get();
      fakeDataSource.docResult = doc;

      await repository.getAccountData('user-1');

      expect(fakeDataSource.getDocCallCount, 1);
      expect(fakeDataSource.lastDocId, 'user-1');
      expect(fakeDataSource.lastDocCollectionPath, FirestoreSchema.accounts);
    });
  });

  group('getPostCounts', () {
    test('delegates to dataSource.getPostCounts', () async {
      fakeDataSource.postCountsResult = (commentsCount: 3, likesCount: 5);

      final result = await repository.getPostCounts('post-1');

      expect(result.likesCount, 5);
      expect(result.commentsCount, 3);
      expect(fakeDataSource.getPostCountsCallCount, 1);
      expect(fakeDataSource.lastPostCountsPostId, 'post-1');
    });
  });

  group('getFriendsForStatus', () {
    test('calls getQuery with currentUid and users/friends', () async {
      final snapshot = await fakeFirestore
          .collection(FirestoreSchema.users)
          .doc('uid-1')
          .collection(FirestoreSchema.friends)
          .get();
      fakeDataSource.queryResult = snapshot;

      await repository.getFriendsForStatus(
        limit: 5,
        lastStatusDoc: null,
      );

      expect(fakeDataSource.getQueryCallCount, 1);
    });
  });

  group('getDeletedStatuses', () {
    test('calls getSubCollection with users/{uid}/deleted_statuses', () async {
      final snapshot = await fakeFirestore
          .collection(FirestoreSchema.users)
          .doc('uid-1')
          .collection('deleted_statuses')
          .get();
      fakeDataSource.subCollectionResult = snapshot;

      await repository.getDeletedStatuses();

      expect(fakeDataSource.lastSubDocId, 'uid-1');
      expect(fakeDataSource.lastSubSupCollectionPath, FirestoreSchema.users);
      expect(fakeDataSource.lastSubSubCollectionPath, 'deleted_statuses');
    });
  });

  group('getStatusesForUser', () {
    test('delegates to dataSource.getStatusesByUser', () async {
      final snapshot = await fakeFirestore.collection('status').get();
      fakeDataSource.statusesByUserResult = snapshot;

      await repository.getStatusesForUser('user-1');

      expect(fakeDataSource.getStatusesByUserCallCount, 1);
      expect(fakeDataSource.lastStatusesByUserUserId, 'user-1');
    });
  });

  group('addPostToFirestore', () {
    test('calls getRefAndSetDoc with posts, isMerge true, and toJson',
            () async {
          final postModel = PostModel(
            myId: 'uid-1',
            myDocId: 'post-1',
            userText: 'Hello',
            myState: 'public',
            myDateTime: DateTime(2024, 5, 1),
          );

          await repository.addPostToFirestore(postModel);

          expect(fakeDataSource.getRefAndSetDocCallCount, 1);
          expect(fakeDataSource.lastSetCollectionPath, FirestoreSchema.posts);
          expect(fakeDataSource.lastSetDocId, 'post-1');
          expect(fakeDataSource.lastSetIsMerge, true);
          expect(fakeDataSource.lastSetData, postModel.toJson());
        });
  });

  group('addStatusToFirestore', () {
    test('calls getRefAndSetDoc with status collection, isMerge true',
            () async {
          final statusModel = PostModel(
            myId: 'uid-1',
            myDocId: 'status-1',
            userText: 'Status',
            myState: 'public',
            myDateTime: DateTime(2024, 5, 1),
          );

          await repository.addStatusToFirestore(statusModel);

          expect(fakeDataSource.getRefAndSetDocCallCount, 1);
          expect(fakeDataSource.lastSetCollectionPath, PublicConstants.status);
          expect(fakeDataSource.lastSetDocId, 'status-1');
          expect(fakeDataSource.lastSetIsMerge, true);
        });
  });

  group('deletePostFromFirestore', () {
    test('calls deleteSupDoc with posts and postId', () async {
      await repository.deletePostFromFirestore('post-1');

      expect(fakeDataSource.deleteSupDocCallCount, 1);
      expect(fakeDataSource.lastDeleteCollectionPath, FirestoreSchema.posts);
      expect(fakeDataSource.lastDeleteDocId, 'post-1');
    });
  });

  group('addToDeletedPosts', () {
    test('calls setSubDoc with users/{uid}/deleted_posts/{postId} and {}',
            () async {
          await repository.addToDeletedPosts('post-1');

          expect(fakeDataSource.setSubDocCallCount, 1);
          expect(fakeDataSource.lastSetSubSupDocId, 'uid-1');
          expect(fakeDataSource.lastSetSubSubDocId, 'post-1');
          expect(
              fakeDataSource.lastSetSupCollectionPath, FirestoreSchema.users);
          expect(fakeDataSource.lastSetSubCollectionPath, 'deleted_posts');
          expect(fakeDataSource.lastSetSubData, {});
        });
  });

  group('deleteStatusFromFirestore', () {
    test('calls deleteSupDoc with status collection and statusId', () async {
      await repository.deleteStatusFromFirestore('status-1');

      expect(fakeDataSource.deleteSupDocCallCount, 1);
      expect(fakeDataSource.lastDeleteCollectionPath, PublicConstants.status);
      expect(fakeDataSource.lastDeleteDocId, 'status-1');
    });
  });

  group('addToDeletedStatuses', () {
    test('calls setSubDoc with users/{uid}/deleted_statuses/{statusId} and {}',
            () async {
          await repository.addToDeletedStatuses('status-1');

          expect(fakeDataSource.setSubDocCallCount, 1);
          expect(fakeDataSource.lastSetSubSupDocId, 'uid-1');
          expect(fakeDataSource.lastSetSubSubDocId, 'status-1');
          expect(
              fakeDataSource.lastSetSupCollectionPath, FirestoreSchema.users);
          expect(fakeDataSource.lastSetSubCollectionPath, 'deleted_statuses');
          expect(fakeDataSource.lastSetSubData, {});
        });
  });

  group('getAccountMap (bug: infinite recursion)', () {
    test('throws StackOverflowError (documents bug)', () async {
      final userDoc = await fakeFirestore.collection('accounts')
          .doc('u1')
          .get();

      // ← bug: getAccountMap يستدعي نفسه
      expect(
            () => repository.getAccountMap(userDoc),
        throwsA(isA<StackOverflowError>()),
      );
    });
  });
}