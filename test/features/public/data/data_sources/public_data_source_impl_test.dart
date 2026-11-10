import 'package:flutter_test/flutter_test.dart';
import 'package:social_app/core/constants/app_strings.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:social_app/core/constants/firestore_schema.dart';
import 'package:social_app/features/public/constants/public_constants.dart';
import 'package:social_app/features/public/data/data_sources/public_data_source_impl.dart';


void main() {
  late FakeFirebaseFirestore fakeFirestore;
  late PublicDataSourceImpl dataSource;

  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
    dataSource = PublicDataSourceImpl(firestore: fakeFirestore);
  });

  group('getQuery', () {
    test('returns query results with limit', () async {
      await fakeFirestore
          .collection('users')
          .doc('uid-1')
          .collection('statuses')
          .doc('1')
          .set({'text': 'A'});
      await fakeFirestore
          .collection('users')
          .doc('uid-1')
          .collection('statuses')
          .doc('2')
          .set({'text': 'B'});
      await fakeFirestore
          .collection('users')
          .doc('uid-1')
          .collection('statuses')
          .doc('3')
          .set({'text': 'C'});

      final result = await dataSource.getQuery(
        limit: 2,
        docId: 'uid-1',
        supCollectionPath: 'users',
        subCollectionPath: 'statuses',
        lastStatusDoc: null,
      );

      expect(result.docs.length, 2);
    });

    test('uses startAfterDocument when lastStatusDoc provided', () async {
      for (int i = 1; i <= 5; i++) {
        await fakeFirestore
            .collection('users')
            .doc('uid-1')
            .collection('statuses')
            .doc('$i')
            .set({'text': 'S$i'});
      }

      final firstPage = await dataSource.getQuery(
        limit: 2,
        docId: 'uid-1',
        supCollectionPath: 'users',
        subCollectionPath: 'statuses',
        lastStatusDoc: null,
      );
      expect(firstPage.docs.length, 2);

      final lastDoc = firstPage.docs.last;
      final secondPage = await dataSource.getQuery(
        limit: 2,
        docId: 'uid-1',
        supCollectionPath: 'users',
        subCollectionPath: 'statuses',
        lastStatusDoc: lastDoc,
      );
      expect(secondPage.docs.length, 2);
      expect(secondPage.docs.first.id, isNot(firstPage.docs.first.id));
    });

    test('returns empty for empty collection', () async {
      final result = await dataSource.getQuery(
        limit: 10,
        docId: 'uid-1',
        supCollectionPath: 'users',
        subCollectionPath: 'statuses',
        lastStatusDoc: null,
      );

      expect(result.docs, isEmpty);
    });
  });

  group('getStatusesByUser', () {
    test('returns statuses filtered by userId', () async {
      await fakeFirestore.collection(PublicConstants.status).doc('1').set({
        AppStrings.userId: 'uid-1',
        AppStrings.dateTime: DateTime(2024, 5, 1),
      });
      await fakeFirestore.collection(PublicConstants.status).doc('2').set({
        AppStrings.userId: 'uid-1',
        AppStrings.dateTime: DateTime(2024, 5, 2),
      });
      await fakeFirestore.collection(PublicConstants.status).doc('3').set({
        AppStrings.userId: 'uid-2',
        AppStrings.dateTime: DateTime(2024, 5, 3),
      });

      final result = await dataSource.getStatusesByUser(userId: 'uid-1');

      expect(result.docs.length, 2);
      expect(
        result.docs.every((d) => d.data()[AppStrings.userId] == 'uid-1'),
        true,
      );
    });

    test('orders by dateTime descending', () async {
      await fakeFirestore.collection(PublicConstants.status).doc('1').set({
        AppStrings.userId: 'uid-1',
        AppStrings.dateTime: DateTime(2024, 5, 1),
      });
      await fakeFirestore.collection(PublicConstants.status).doc('2').set({
        AppStrings.userId: 'uid-1',
        AppStrings.dateTime: DateTime(2024, 5, 3),
      });
      await fakeFirestore.collection(PublicConstants.status).doc('3').set({
        AppStrings.userId: 'uid-1',
        AppStrings.dateTime: DateTime(2024, 5, 2),
      });

      final result = await dataSource.getStatusesByUser(userId: 'uid-1');

      // الأحدث أولاً
      expect(result.docs.first.id, '2'); // May 3
      expect(result.docs.last.id, '1'); // May 1
    });
  });

  group('getDocumentsWithWhereIn', () {
    test('returns posts filtered by friendsUIds and postType', () async {
      await fakeFirestore.collection(FirestoreSchema.posts).doc('1').set({
        AppStrings.userId: 'friend-1',
        AppStrings.postType: 'public',
      });
      await fakeFirestore.collection(FirestoreSchema.posts).doc('2').set({
        AppStrings.userId: 'friend-2',
        AppStrings.postType: 'public',
      });
      await fakeFirestore.collection(FirestoreSchema.posts).doc('3').set({
        AppStrings.userId: 'stranger',
        AppStrings.postType: 'public',
      });

      final result = await dataSource.getDocumentsWithWhereIn(
        lastPostDoc: null,
        friendsUIds: ['friend-1', 'friend-2'],
        limit: 10,
      );

      expect(result.docs.length, 2);
    });

    test('returns empty when friendsUIds is empty', () async {
      final result = await dataSource.getDocumentsWithWhereIn(
        lastPostDoc: null,
        friendsUIds: [],
        limit: 10,
      );

      expect(result.docs, isEmpty);
    });
  });

  group('getPostCounts', () {
    test('returns counts for likes and comments', () async {
      await fakeFirestore.collection(FirestoreSchema.posts).doc('post-1').set({
        'text': 'Post',
      });
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

      final result = await dataSource.getPostCounts('post-1');

      expect(result.likesCount, 2);
      expect(result.commentsCount, 1);
    });

    test('returns 0 counts for post without likes/comments', () async {
      await fakeFirestore.collection(FirestoreSchema.posts).doc('post-1').set({
        'text': 'Post',
      });

      final result = await dataSource.getPostCounts('post-1');

      expect(result.likesCount, 0);
      expect(result.commentsCount, 0);
    });
  });
}