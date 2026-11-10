import 'package:mocktail/mocktail.dart';
import 'package:flutter_test/flutter_test.dart';
import '../../../../fakes/fake_profile_data_source.dart';
import '../../../../fakes/mock_session_service.dart';
import '../../../../fakes/fake_user_account_service.dart';
import 'package:social_app/core/data/models/my_model.dart';
import 'package:social_app/core/constants/app_strings.dart';
import 'package:social_app/core/data/models/post_model.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:social_app/core/constants/firestore_schema.dart';
import 'package:social_app/features/profile/domain/repositories/profile_repository.dart';
import 'package:social_app/features/profile/data/data_sources/profile_data_source_impl.dart';
import 'package:social_app/features/profile/data/repositories_impl/profile_repository_impl.dart';


void main() {
  late ProfileRepository repository;
  late MockSessionService mockSession;
  late FakeFirebaseFirestore fakeFirestore;
  late FakeProfileDataSource fakeDataSource;
  late FakeUserAccountService fakeAccountService;

  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
    fakeDataSource = FakeProfileDataSource();
    mockSession = MockSessionService();
    fakeAccountService = FakeUserAccountService();
    when(() => mockSession.currentUid).thenReturn('uid-1');
    repository = ProfileRepositoryImpl(
      dataSource: fakeDataSource,
      sessionService: mockSession,
      userAccountService: fakeAccountService,
    );
  });

  group('getProfileInfo', () {
    test('returns info and account documents', () async {
      await fakeFirestore.collection('info').doc('user-1').set({'userState': 'Single'});
      await fakeFirestore.collection(FirestoreSchema.accounts).doc('user-1').set({'userId': 'user-1'});

      final infoDoc = await fakeFirestore.collection('info').doc('user-1').get();
      final accountDoc = await fakeFirestore.collection(FirestoreSchema.accounts).doc('user-1').get();

      fakeDataSource.docResponses = {
        'info/user-1': infoDoc,
        'accounts/user-1': accountDoc,
      };

      final result = await repository.getProfileInfo('user-1');

      expect(result.info, isNotNull);
      expect(result.account, isNotNull);
    });
  });

  group('getPosts', () {
    test('delegates to dataSource.getPosts', () async {
      final snapshot = await fakeFirestore.collection('posts').get();
      fakeDataSource.postsResult = snapshot;
      final lastDoc = await fakeFirestore.collection('x').doc('d1').get();

      await repository.getPosts(
        userId: 'user-1',
        limit: 10,
        lastDoc: lastDoc,
      );

      expect(fakeDataSource.getPostsCallCount, 1);
      expect(fakeDataSource.lastUserId, 'user-1');
      expect(fakeDataSource.lastLimit, 10);
      expect(fakeDataSource.lastLastPostDoc, same(lastDoc));
    });
  });

  group('getVideos', () {
    test('passes postType video', () async {
      final snapshot = await fakeFirestore.collection('posts').get();
      fakeDataSource.postsResult = snapshot;

      await repository.getVideos(
        userId: 'user-1',
        limit: 10,
        lastDoc: null,
      );

      expect(fakeDataSource.lastPostType, AppStrings.video);
    });
  });

  group('getAccountData', () {
    test('calls getDoc and getAccountMap', () async {
      await fakeFirestore.collection(FirestoreSchema.accounts).doc('user-1').set({'userId': 'user-1'});
      final doc = await fakeFirestore.collection(FirestoreSchema.accounts).doc('user-1').get();
      fakeDataSource.docResponses = {'accounts/user-1': doc};
      fakeAccountService.getAccountMapResult = {'userId': 'user-1'};

      final result = await repository.getAccountData('user-1');

      expect(result['userId'], 'user-1');
      expect(fakeAccountService.getAccountMapCallCount, 1);
    });
  });

  group('getPostCounts', () {
    test('returns likes and comments counts', () async {
      await fakeFirestore.collection(FirestoreSchema.posts).doc('post-1').set({});
      await fakeFirestore
          .collection(FirestoreSchema.posts)
          .doc('post-1')
          .collection(AppStrings.likesList)
          .doc('like-1')
          .set({});
      await fakeFirestore
          .collection(FirestoreSchema.posts)
          .doc('post-1')
          .collection(AppStrings.likesList)
          .doc('like-2')
          .set({});
      await fakeFirestore
          .collection(FirestoreSchema.posts)
          .doc('post-1')
          .collection(AppStrings.commentsList)
          .doc('comment-1')
          .set({});

      final realDataSource = ProfileDataSourceImpl(firestore: fakeFirestore);
      final realRepository = ProfileRepositoryImpl(
        dataSource: realDataSource,
        sessionService: mockSession,
        userAccountService: fakeAccountService,
      );

      final result = await realRepository.getPostCounts('post-1');

      expect(result.likes, 2);
      expect(result.comments, 1);
    });
  });

  group('uploadImage', () {
    test('passes currentUid from sessionService', () async {
      fakeDataSource.uploadImageResult = 'new-post-id';
      final postModel = PostModel(myId: 'uid-1', myDateTime: DateTime(2024));

      final result = await repository.uploadImage(
        imageType: AppStrings.userImage,
        postModel: postModel,
        collectionPath: FirestoreSchema.accounts,
      );

      expect(result, 'new-post-id');
      expect(fakeDataSource.lastCurrentUid, 'uid-1');
    });
  });

  group('sendFriendRequest', () {
    test('calls setSubDoc with users/{userId}/requests/{friendInfo.myId}',
            () async {
          final friendInfo = MyModel(myId: 'friend-1', myDateTime: DateTime(2024));

          await repository.sendFriendRequest('user-1', friendInfo);

          expect(fakeDataSource.setSubDocCallCount, 1);
          expect(fakeDataSource.lastSetSubSupDocId, 'user-1');
          expect(fakeDataSource.lastSetSubSubDocId, 'friend-1');
          expect(fakeDataSource.lastSetSubSupCollectionPath, FirestoreSchema.users);
          expect(fakeDataSource.lastSetSubSubCollectionPath, FirestoreSchema.requests);
          expect(fakeDataSource.lastSetSubData, friendInfo.toJson());
        });
  });

  group('deleteFriendRequest', () {
    test('calls deleteSubDoc with users/{userId}/requests/{currentUid}',
            () async {
          await repository.deleteFriendRequest('user-1');

          expect(fakeDataSource.deleteSubDocCallCount, 1);
          expect(fakeDataSource.lastDeleteSupDoc, 'user-1');
          expect(fakeDataSource.lastDeleteSubDoc, 'uid-1');
          expect(fakeDataSource.lastDeleteSupCollectionPath, FirestoreSchema.users);
          expect(fakeDataSource.lastDeleteSubCollectionPath, FirestoreSchema.requests);
        });
  });

  group('deleteFriendship', () {
    test('calls deleteSubDoc twice (both directions)', () async {
      await repository.deleteFriendship('user-2');

      expect(fakeDataSource.deleteSubDocCallCount, 2);
    });
  });

  group('addFriend', () {
    test('calls setSubDoc with users/{friendInfo.myId}/friends/{docId}',
            () async {
          final friendInfo = MyModel(myId: 'friend-1', myDateTime: DateTime(2024));

          await repository.addFriend('doc-1', friendInfo);

          expect(fakeDataSource.setSubDocCallCount, 1);
          expect(fakeDataSource.lastSetSubSupDocId, 'friend-1');
          expect(fakeDataSource.lastSetSubSubDocId, 'doc-1');
          expect(fakeDataSource.lastSetSubSupCollectionPath, FirestoreSchema.users);
          expect(fakeDataSource.lastSetSubSubCollectionPath, FirestoreSchema.friends);
        });
  });

  group('getFriends', () {
    test('returns list of MyModel', () async {
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
      fakeAccountService.getUserModelDataResult = MyModel(myId: 'friend-1', myDateTime: DateTime(2024));

      final result = await repository.getFriends('uid-1');

      expect(result.length, 1);
      expect(result.first.myId, 'friend-1');
    });
  });

  group('checkRequestExists', () {
    test('returns true when request exists', () async {
      await fakeFirestore
          .collection(FirestoreSchema.users)
          .doc('uid-1')
          .collection(FirestoreSchema.requests)
          .doc('user-2')
          .set({});
      final doc = await fakeFirestore
          .collection(FirestoreSchema.users)
          .doc('uid-1')
          .collection(FirestoreSchema.requests)
          .doc('user-2')
          .get();
      fakeDataSource.subDocResponses = {'users/uid-1/requests/user-2': doc};

      final result = await repository.checkRequestExists('user-2');

      expect(result, true);
    });

    test('returns false when request does not exist', () async {
      final doc = await fakeFirestore
          .collection(FirestoreSchema.users)
          .doc('uid-1')
          .collection(FirestoreSchema.requests)
          .doc('missing')
          .get();
      fakeDataSource.subDocResponses = {'users/uid-1/requests/missing': doc};

      final result = await repository.checkRequestExists('missing');

      expect(result, false);
    });
  });

  group('checkFriendExists', () {
    test('returns true when friend exists', () async {
      await fakeFirestore
          .collection(FirestoreSchema.users)
          .doc('uid-1')
          .collection(FirestoreSchema.friends)
          .doc('user-2')
          .set({});
      final doc = await fakeFirestore
          .collection(FirestoreSchema.users)
          .doc('uid-1')
          .collection(FirestoreSchema.friends)
          .doc('user-2')
          .get();
      fakeDataSource.subDocResponses = {'users/uid-1/friends/user-2': doc};

      final result = await repository.checkFriendExists('user-2');

      expect(result, true);
    });
  });
}