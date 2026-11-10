import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:social_app/core/domain/data_sources/remote/firestore/firestore_service.dart';
import 'package:social_app/core/data/data_sources/remote/firestore/firestore_service_impl.dart';


void main() {
  late FakeFirebaseFirestore fakeFirestore;
  late FirestoreService service;

  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
    service = FirestoreServiceImpl(firestore: fakeFirestore);
  });

  group('FirestoreServiceImpl - getRefAndSetDoc', () {
    test('creates a doc with auto id and returns it', () async {
      final id = await service.getRefAndSetDoc(
        isMerge: false,
        collectionPath: 'users',
        data: {'name': 'Ali'},
      );

      expect(id, isNotEmpty);

      final snapshot =
      await fakeFirestore.collection('users').doc(id).get();
      expect(snapshot.data()?['name'], 'Ali');
    });

    test('sets doc with provided id', () async {
      await service.getRefAndSetDoc(
        docId: 'user-1',
        isMerge: false,
        collectionPath: 'users',
        data: {'name': 'Sara'},
      );

      final snapshot =
      await fakeFirestore.collection('users').doc('user-1').get();
      expect(snapshot.data()?['name'], 'Sara');
    });
  });

  group('FirestoreServiceImpl - getDoc', () {
    test('returns the document snapshot', () async {
      await fakeFirestore.collection('users').doc('u1').set({'name': 'Omar'});

      final snapshot =
      await service.getDoc(collectionPath: 'users', docId: 'u1');
      expect(snapshot.data()?['name'], 'Omar');
    });
  });

  group('FirestoreServiceImpl - updateDoc', () {
    test('updates existing document fields', () async {
      await fakeFirestore.collection('users').doc('u1').set({'name': 'Ali'});

      await service.updateDoc(
        docId: 'u1',
        collectionPath: 'users',
        data: {'name': 'Ali Updated'},
      );

      final snapshot =
      await fakeFirestore.collection('users').doc('u1').get();
      expect(snapshot.data()?['name'], 'Ali Updated');
    });

    test('throws when document does not exist', () async {
      expect(
            () => service.updateDoc(
          docId: 'missing',
          collectionPath: 'users',
          data: {'name': 'X'},
        ),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('FirestoreServiceImpl - getSupCollection', () {
    test('returns all docs in collection', () async {
      await fakeFirestore.collection('posts').doc('p1').set({'title': 'A'});
      await fakeFirestore.collection('posts').doc('p2').set({'title': 'B'});

      final result = await service.getSupCollection(collectionPath: 'posts');
      expect(result.docs.length, 2);
    });
  });

  group('FirestoreServiceImpl - deleteSupDoc', () {
    test('removes the document', () async {
      await fakeFirestore.collection('users').doc('u1').set({'name': 'Ali'});

      await service.deleteSupDoc(collectionPath: 'users', docId: 'u1');

      final snapshot =
      await fakeFirestore.collection('users').doc('u1').get();
      expect(snapshot.exists, false);
    });
  });
}