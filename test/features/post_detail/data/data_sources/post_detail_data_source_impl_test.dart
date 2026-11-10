import 'package:flutter_test/flutter_test.dart';
import 'package:social_app/core/constants/app_strings.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:social_app/core/constants/firestore_schema.dart';
import 'package:social_app/features/post_detail/data/data_sources/post_detail_data_source_impl.dart';


void main() {
  late FakeFirebaseFirestore fakeFirestore;
  late PostDetailDataSourceImpl dataSource;

  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
    dataSource = PostDetailDataSourceImpl(firestore: fakeFirestore);
  });

  group('getPostData', () {
    test('returns post, user, and comments docs', () async {
      await fakeFirestore.collection(FirestoreSchema.posts).doc('post-1').set({
        AppStrings.userId: 'uid-1',
        AppStrings.userText: 'Hello',
      });
      await fakeFirestore.collection(FirestoreSchema.accounts).doc('uid-1').set(
          {
            AppStrings.userName: 'Ali',
          });
      await fakeFirestore
          .collection(FirestoreSchema.posts)
          .doc('post-1')
          .collection(AppStrings.commentsList)
          .doc('comment-1')
          .set({'text': 'Nice'});

      final result = await dataSource.getPostData(
        postId: 'post-1',
        userId: 'uid-1',
      );

      expect(result.postDoc.exists, true);
      expect(result.postDoc.data()?[AppStrings.userText], 'Hello');
      expect(result.userDoc.exists, true);
      expect(result.userDoc.data()?[AppStrings.userName], 'Ali');
      expect(result.commentsDocs.docs.length, 1);
    });

    test('returns empty comments when no comments', () async {
      await fakeFirestore.collection(FirestoreSchema.posts).doc('post-1').set(
          {});
      await fakeFirestore.collection(FirestoreSchema.accounts).doc('uid-1').set(
          {});

      final result = await dataSource.getPostData(
        postId: 'post-1',
        userId: 'uid-1',
      );

      expect(result.commentsDocs.docs, isEmpty);
    });
  });

  group('getCommentsWithLikes', () {
    test('adds likesCount to each comment', () async {
      await fakeFirestore.collection(FirestoreSchema.posts).doc('post-1').set(
          {});

      // 2 comments
      await fakeFirestore
          .collection(FirestoreSchema.posts)
          .doc('post-1')
          .collection(AppStrings.commentsList)
          .doc('comment-1')
          .set({'text': 'First'});
      await fakeFirestore
          .collection(FirestoreSchema.posts)
          .doc('post-1')
          .collection(AppStrings.commentsList)
          .doc('comment-2')
          .set({'text': 'Second'});

      // 2 likes on comment-1
      await fakeFirestore
          .collection(FirestoreSchema.posts)
          .doc('post-1')
          .collection(AppStrings.commentsList)
          .doc('comment-1')
          .collection(AppStrings.commentsLikes)
          .doc('like-1')
          .set({});
      await fakeFirestore
          .collection(FirestoreSchema.posts)
          .doc('post-1')
          .collection(AppStrings.commentsList)
          .doc('comment-1')
          .collection(AppStrings.commentsLikes)
          .doc('like-2')
          .set({});

      final commentsDocs = await fakeFirestore
          .collection(FirestoreSchema.posts)
          .doc('post-1')
          .collection(AppStrings.commentsList)
          .get();

      final result = await dataSource.getCommentsWithLikes(
        postId: 'post-1',
        commentsDocs: commentsDocs,
      );

      expect(result.length, 2);

      // comment-1 — likesNumber = 2
      final comment1 = result.firstWhere((d) => d.id == 'comment-1');
      expect(comment1.data()[AppStrings.likesNumber], 2);

      // comment-2 — likesNumber = 0
      final comment2 = result.firstWhere((d) => d.id == 'comment-2');
      expect(comment2.data()[AppStrings.likesNumber], 0);
    });

    test('returns empty list when commentsDocs is empty', () async {
      final emptyComments = await fakeFirestore
          .collection(FirestoreSchema.posts)
          .doc('post-1')
          .collection(AppStrings.commentsList)
          .get();

      final result = await dataSource.getCommentsWithLikes(
        postId: 'post-1',
        commentsDocs: emptyComments,
      );

      expect(result, isEmpty);
    });
  });

  group('getAccountMap', () {
    test('returns userId, userName, userImage', () async {
      await fakeFirestore.collection(FirestoreSchema.accounts).doc('uid-1').set(
          {
            AppStrings.userName: 'Ali',
            AppStrings.userImage: 'url',
          });
      final userDoc = await fakeFirestore
          .collection(FirestoreSchema.accounts)
          .doc('uid-1')
          .get();

      final result = await dataSource.getAccountMap(userDoc: userDoc);

      expect(result[AppStrings.userId], 'uid-1');
      expect(result[AppStrings.userName], 'Ali');
      expect(result[AppStrings.userImage], 'url');
    });

    test('returns empty strings when fields are missing', () async {
      await fakeFirestore.collection(FirestoreSchema.accounts).doc('uid-1').set(
          {});
      final userDoc = await fakeFirestore
          .collection(FirestoreSchema.accounts)
          .doc('uid-1')
          .get();

      final result = await dataSource.getAccountMap(userDoc: userDoc);

      expect(result[AppStrings.userId], 'uid-1');
      expect(result[AppStrings.userName], AppStrings.empty);
      expect(result[AppStrings.userImage], AppStrings.empty);
    });

    test('uses docId as userId', () async {
      await fakeFirestore.collection(FirestoreSchema.accounts)
          .doc('custom-id')
          .set({
        AppStrings.userName: 'Sara',
      });
      final userDoc = await fakeFirestore
          .collection(FirestoreSchema.accounts)
          .doc('custom-id')
          .get();

      final result = await dataSource.getAccountMap(userDoc: userDoc);

      expect(result[AppStrings.userId], 'custom-id');
    });
  });
}