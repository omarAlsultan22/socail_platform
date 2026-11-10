import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:social_app/features/user_details/data/data_sources/user_details_data_source_impl.dart';

void main() {
  late FakeFirebaseFirestore fakeFirestore;
  late UserDetailsDataSourceImpl dataSource;

  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
    dataSource = UserDetailsDataSourceImpl(firestore: fakeFirestore);
  });

  group('getMyDetailsStream', () {
    test('emits document snapshot', () async {
      await fakeFirestore.collection('users').doc('uid-1').set({
        'name': 'Ali',
        'age': 25,
      });

      final stream = dataSource.getMyDetailsStream(
        docId: 'uid-1',
        collectionPath: 'users',
      );

      final snapshot = await stream.first;
      expect(snapshot.exists, true);
      expect(snapshot.data()?['name'], 'Ali');
    });

    test('emits updated snapshot after change', () async {
      await fakeFirestore.collection('users').doc('uid-1').set({'name': 'Ali'});

      final stream = dataSource.getMyDetailsStream(
        docId: 'uid-1',
        collectionPath: 'users',
      );

      final first = await stream.first;
      expect(first.data()?['name'], 'Ali');

      await fakeFirestore.collection('users').doc('uid-1').update({'name': 'Sara'});

      final second = await stream.first;
      expect(second.data()?['name'], 'Sara');
    });

    test('uses correct collection path and docId', () async {
      await fakeFirestore.collection('posts').doc('post-1').set({'title': 'X'});

      final stream = dataSource.getMyDetailsStream(
        docId: 'post-1',
        collectionPath: 'posts',
      );

      final snapshot = await stream.first;
      expect(snapshot.data()?['title'], 'X');
    });
  });

  group('getSubCollectionStream (bug: infinite recursion)', () {
    test('throws StackOverflowError (documents bug)', () async {
      await fakeFirestore
          .collection('users')
          .doc('uid-1')
          .collection('posts')
          .doc('post-1')
          .set({'title': 'X'});

      // ← bug: getSubCollectionStream يستدعي نفسه
      expect(
            () => dataSource.getSubCollectionStream(
          docId: 'uid-1',
          supCollectionPath: 'users',
          subCollectionPath: 'posts',
        ),
        throwsA(isA<StackOverflowError>()),
      );
    });
  });
}