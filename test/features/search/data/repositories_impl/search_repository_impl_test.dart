import 'package:flutter_test/flutter_test.dart';
import '../../../../fakes/fake_search_data_source.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:social_app/core/constants/firestore_schema.dart';
import 'package:social_app/features/search/domain/repositories/search_repository.dart';
import 'package:social_app/features/search/data/repositories_impl/search_repository_impl.dart';


void main() {
  late FakeFirebaseFirestore fakeFirestore;
  late FakeSearchDataSource fakeDataSource;
  late SearchRepository repository;

  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
    fakeDataSource = FakeSearchDataSource();
    repository = SearchRepositoryImpl(dataSource: fakeDataSource);
  });

  group('getDataSearch (bug: returns null)', () {
    test('calls getSupCollection with users collection', () async {
      final emptySnapshot =
      await fakeFirestore.collection(FirestoreSchema.users).get();
      fakeDataSource.collectionToReturn = emptySnapshot;
      fakeDataSource.searchResult =
      await fakeFirestore.collection('accounts').get();

      await repository.getDataSearch(query: 'Ali');

      expect(fakeDataSource.getSupCollectionCallCount, 1);
      expect(fakeDataSource.lastGetSupCollectionPath, FirestoreSchema.users);
    });

    test('returns null (documents bug)', () async {
      final emptySnapshot =
      await fakeFirestore.collection(FirestoreSchema.users).get();
      fakeDataSource.collectionToReturn = emptySnapshot;
      fakeDataSource.searchResult =
      await fakeFirestore.collection('accounts').get();

      final result = await repository.getDataSearch(query: 'Ali');

      // ← bug: return null دائماً
      expect(result, isNull);
    });

    test('calls getDataSearch once per user (documents inefficiency)',
            () async {
          // 3 users
          await fakeFirestore.collection(FirestoreSchema.users).doc('1').set(
              {});
          await fakeFirestore.collection(FirestoreSchema.users).doc('2').set(
              {});
          await fakeFirestore.collection(FirestoreSchema.users).doc('3').set(
              {});

          final usersSnapshot =
          await fakeFirestore.collection(FirestoreSchema.users).get();
          fakeDataSource.collectionToReturn = usersSnapshot;
          fakeDataSource.searchResult =
          await fakeFirestore.collection('accounts').get();

          await repository.getDataSearch(query: 'Ali');

          // ← bug: getDataSearch 3 مرات (نفس query)
          expect(fakeDataSource.getDataSearchCallCount, 3);
          expect(fakeDataSource.lastQuery, 'Ali');
        });

    test('returns null even with matching results', () async {
      await fakeFirestore.collection(FirestoreSchema.users).doc('1').set({});
      await fakeFirestore
          .collection(FirestoreSchema.accounts)
          .doc('1')
          .set({'fullName': 'Ali Ahmed'});

      final usersSnapshot =
      await fakeFirestore.collection(FirestoreSchema.users).get();
      final accountsSnapshot =
      await fakeFirestore.collection(FirestoreSchema.accounts).get();
      fakeDataSource.collectionToReturn = usersSnapshot;
      fakeDataSource.searchResult = accountsSnapshot;

      final result = await repository.getDataSearch(query: 'Ali');

      // ← bug: null — رغم وجود 'Ali Ahmed'
      expect(result, isNull);
    });

    test('returns null when users collection is empty', () async {
      final emptyUsers =
      await fakeFirestore.collection(FirestoreSchema.users).get();
      fakeDataSource.collectionToReturn = emptyUsers;
      fakeDataSource.searchResult =
      await fakeFirestore.collection('accounts').get();

      final result = await repository.getDataSearch(query: 'Ali');

      expect(result, isNull);
    });
  });
}