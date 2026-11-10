import 'package:flutter_test/flutter_test.dart';
import '../../../../fakes/fake_cache_helper.dart';
import 'package:social_app/core/constants/app_strings.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:social_app/core/constants/firestore_schema.dart';
import 'package:social_app/core/services/data/session_service.dart';
import 'package:social_app/core/domain/data_sources/remote/firestore/post_operations.dart';
import 'package:social_app/core/data/data_sources/remote/firestore/post_operations_impl.dart';


void main() {
  late FakeFirebaseFirestore fakeFirestore;
  late SessionService sessionService;
  late PostOperations postOps;

  setUp(() async {
    fakeFirestore = FakeFirebaseFirestore();
    sessionService = SessionService(cacheHelper: FakeCacheHelper());

    await fakeFirestore
        .collection(FirestoreSchema.posts)
        .doc('post-1')
        .set({'isActive': false});

    postOps = PostOperationsImpl(
      sessionService: sessionService,
    );
  });

  group('PostOperationsImpl - addLike', () {
    test('adds like doc and sets isActive=true when user is post owner',
            () async {
          // ← نضبط الـ session على user-1
          await sessionService.login('user-1');

          await postOps.addLike(postId: 'post-1', userId: 'user-1');

          final likeDoc = await fakeFirestore
              .collection(FirestoreSchema.posts)
              .doc('post-1')
              .collection(AppStrings.likesList)
              .doc('user-1')
              .get();
          expect(likeDoc.exists, true);
          expect(likeDoc.data()?['myId'], 'user-1');

          final postDoc = await fakeFirestore
              .collection(FirestoreSchema.posts)
              .doc('post-1')
              .get();
          expect(postDoc.data()?['isActive'], true);
        });

    test('adds like doc but does NOT update isActive when user is not owner',
            () async {
          await sessionService.login('other-user');

          await postOps.addLike(postId: 'post-1', userId: 'user-2');

          final likeDoc = await fakeFirestore
              .collection(FirestoreSchema.posts)
              .doc('post-1')
              .collection(AppStrings.likesList)
              .doc('user-2')
              .get();
          expect(likeDoc.exists, true);

          final postDoc = await fakeFirestore
              .collection(FirestoreSchema.posts)
              .doc('post-1')
              .get();
          expect(postDoc.data()?['isActive'], false);
        });
  });

  group('PostOperationsImpl - removeLike', () {
    test('removes like doc and sets isActive=false when user is owner',
            () async {
          await sessionService.login('user-1');

          await postOps.addLike(postId: 'post-1', userId: 'user-1');
          await postOps.removeLike(postId: 'post-1', userId: 'user-1');

          final likeDoc = await fakeFirestore
              .collection(FirestoreSchema.posts)
              .doc('post-1')
              .collection(AppStrings.likesList)
              .doc('user-1')
              .get();
          expect(likeDoc.exists, false);

          final postDoc = await fakeFirestore
              .collection(FirestoreSchema.posts)
              .doc('post-1')
              .get();
          expect(postDoc.data()?['isActive'], false);
        });
  });

  group('PostOperationsImpl - addShare', () {
    test('adds share doc and sets isActive=true when user is owner', () async {
      await sessionService.login('user-1');

      await postOps.addShare(postId: 'post-1', userId: 'user-1');

      final shareDoc = await fakeFirestore
          .collection(FirestoreSchema.posts)
          .doc('post-1')
          .collection(AppStrings.sharesList)
          .doc('user-1')
          .get();
      expect(shareDoc.exists, true);

      final postDoc = await fakeFirestore
          .collection(FirestoreSchema.posts)
          .doc('post-1')
          .get();
      expect(postDoc.data()?['isActive'], true);
    });
  });

  group('PostOperationsImpl - removeShare', () {
    test('removes share doc and sets isActive=false when user is owner',
            () async {
          await sessionService.login('user-1');

          await postOps.addShare(postId: 'post-1', userId: 'user-1');
          await postOps.removeShare(postId: 'post-1', userId: 'user-1');

          final shareDoc = await fakeFirestore
              .collection(FirestoreSchema.posts)
              .doc('post-1')
              .collection(AppStrings.sharesList)
              .doc('user-1')
              .get();
          expect(shareDoc.exists, false);

          final postDoc = await fakeFirestore
              .collection(FirestoreSchema.posts)
              .doc('post-1')
              .get();
          expect(postDoc.data()?['isActive'], false);
        });
  });
}