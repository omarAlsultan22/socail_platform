import 'package:flutter_test/flutter_test.dart';
import 'package:social_app/core/constants/app_strings.dart';
import 'package:social_app/core/data/models/post_model.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:social_app/core/constants/firestore_schema.dart';
import 'package:social_app/features/profile/data/data_sources/profile_data_source_impl.dart';


void main() {
  late FakeFirebaseFirestore fakeFirestore;
  late ProfileDataSourceImpl dataSource;

  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
    dataSource = ProfileDataSourceImpl(firestore: fakeFirestore);
  });

  group('createAndSetDoc', () {
    test('sets doc with auto-generated id', () async {
      final id = await dataSource.createAndSetDoc(
        collectionPath: 'users',
        data: {'name': 'Ali'},
        isMerge: true,
      );

      expect(id, isNotEmpty);
      final snapshot = await fakeFirestore.collection('users').doc(id).get();
      expect(snapshot.data()?['name'], 'Ali');
    });
  });

  group('createDoc', () {
    test('returns DocumentReference with auto-generated id', () {
      final ref = dataSource.createDoc(collectionPath: 'posts');

      expect(ref.id, isNotEmpty);
      expect(ref.path, startsWith('posts/'));
    });

    test('creates different ids on each call', () {
      final ref1 = dataSource.createDoc(collectionPath: 'posts');
      final ref2 = dataSource.createDoc(collectionPath: 'posts');

      expect(ref1.id, isNot(ref2.id));
    });
  });

  group('getSubDoc', () {
    test('returns subdocument snapshot', () async {
      await fakeFirestore
          .collection('users')
          .doc('user-1')
          .collection('posts')
          .doc('post-1')
          .set({'title': 'Hello'});

      final result = await dataSource.getSubDoc(
        supDoc: 'user-1',
        subDoc: 'post-1',
        supCollectionPath: 'users',
        subCollectionPath: 'posts',
      );

      expect(result.exists, true);
      expect(result.data()?['title'], 'Hello');
    });

    test('returns non-existing when missing', () async {
      final result = await dataSource.getSubDoc(
        supDoc: 'user-1',
        subDoc: 'missing',
        supCollectionPath: 'users',
        subCollectionPath: 'posts',
      );

      expect(result.exists, false);
    });
  });

  group('getPosts', () {
    test('filters posts by userId and postType', () async {
      await fakeFirestore.collection(FirestoreSchema.posts).doc('1').set({
        AppStrings.userId: 'uid-1',
        AppStrings.postType: 'public',
      });
      await fakeFirestore.collection(FirestoreSchema.posts).doc('2').set({
        AppStrings.userId: 'uid-1',
        AppStrings.postType: 'shared',
      });
      await fakeFirestore.collection(FirestoreSchema.posts).doc('3').set({
        AppStrings.userId: 'uid-2',
        AppStrings.postType: 'public',
      });

      final result = await dataSource.getPosts(
        userId: 'uid-1',
        limit: 10,
        lastPostDoc: null,
      );

      expect(result.docs.length, greaterThan(0));
      expect(
        result.docs.every((d) =>
        (d.data() as Map<String, dynamic>)[AppStrings.userId] == 'uid-1'),
        true,
      );
    });

    test('uses postType when provided', () async {
      await fakeFirestore.collection(FirestoreSchema.posts).doc('1').set({
        AppStrings.userId: 'uid-1',
        AppStrings.postType: 'public',
      });
      await fakeFirestore.collection(FirestoreSchema.posts).doc('2').set({
        AppStrings.userId: 'uid-1',
        AppStrings.postType: 'shared',
      });

      final result = await dataSource.getPosts(
        userId: 'uid-1',
        limit: 10,
        postType: 'public',
        lastPostDoc: null,
      );

      expect(result.docs.length, 1);
      expect(result.docs.first.data() ?? [AppStrings.postType], 'public');
    });

    test('uses postTypesList when postType is null', () async {
      await fakeFirestore.collection(FirestoreSchema.posts).doc('1').set({
        AppStrings.userId: 'uid-1',
        AppStrings.postType: 'public',
      });

      final result = await dataSource.getPosts(
        userId: 'uid-1',
        limit: 10,
        postType: null,
        lastPostDoc: null,
      );

      // postTypesList — كل الأنواع
      expect(result.docs.length, greaterThanOrEqualTo(1));
    });
  });

  group('uploadImage', () {
    test('creates post, updates user doc, sets post data', () async {
      final postModel = PostModel(
        myId: 'uid-1',
        userText: 'Image post',
        myState: 'public',
        myDateTime: DateTime(2024, 5, 1),
      );

      final docId = await dataSource.uploadImage(
        imageType: AppStrings.userImage,
        currentUid: 'uid-1',
        postModel: postModel,
        collectionPath: FirestoreSchema.accounts,
      );

      // 1. postModel.myDocId — updated
      expect(postModel.myDocId, docId);

      // 2. post created in posts
      final postDoc = await fakeFirestore
          .collection(FirestoreSchema.posts)
          .doc(docId)
          .get();
      expect(postDoc.exists, true);

      // 3. user doc updated with imageType: posts/{docId}
      final userDoc = await fakeFirestore
          .collection(FirestoreSchema.accounts)
          .doc('uid-1')
          .get();
      expect(userDoc.data()?[AppStrings.userImage], contains('posts/'));
    });

    test('returns generated doc id', () async {
      final postModel = PostModel(
        myId: 'uid-1',
        myDateTime: DateTime(2024, 5, 1),
      );

      final docId = await dataSource.uploadImage(
        imageType: AppStrings.userCover,
        currentUid: 'uid-1',
        postModel: postModel,
        collectionPath: FirestoreSchema.accounts,
      );

      expect(docId, isNotEmpty);
    });
  });
}