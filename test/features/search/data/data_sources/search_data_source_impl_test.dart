import 'package:flutter_test/flutter_test.dart';
import 'package:social_app/core/constants/app_strings.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:social_app/core/constants/firestore_schema.dart';
import 'package:social_app/features/search/data/data_sources/search_data_source_impl.dart';


void main() {
  late SearchDataSourceImpl dataSource;
  late FakeFirebaseFirestore fakeFirestore;

  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
    dataSource = SearchDataSourceImpl(firestore: fakeFirestore);
  });

  group('getDataSearch', () {
    test('returns documents matching query prefix', () async {
      await fakeFirestore.collection(FirestoreSchema.accounts).doc('1').set({
        AppStrings.fullName: 'Ali Ahmed',
      });
      await fakeFirestore.collection(FirestoreSchema.accounts).doc('2').set({
        AppStrings.fullName: 'Ali Hassan',
      });
      await fakeFirestore.collection(FirestoreSchema.accounts).doc('3').set({
        AppStrings.fullName: 'Sara Mohamed',
      });

      final result = await dataSource.getDataSearch(query: 'Ali');

      expect(result.docs.length, 2);
      expect(result.docs.map((d) => d.data()[AppStrings.fullName]),
          containsAll(['Ali Ahmed', 'Ali Hassan']));
    });

    test('returns empty when no match', () async {
      await fakeFirestore.collection(FirestoreSchema.accounts).doc('1').set({
        AppStrings.fullName: 'Ali Ahmed',
      });

      final result = await dataSource.getDataSearch(query: 'zzz');

      expect(result.docs, isEmpty);
    });

    test('searches in accounts collection', () async {
      await fakeFirestore.collection(FirestoreSchema.accounts).doc('1').set({
        AppStrings.fullName: 'Ali',
      });

      final result = await dataSource.getDataSearch(query: 'Ali');

      expect(result.docs.length, 1);
    });

    test('filters by fullName field', () async {
      await fakeFirestore.collection(FirestoreSchema.accounts).doc('1').set({
        AppStrings.fullName: 'Ali Ahmed',
        'firstName': 'Ali',
      });
      await fakeFirestore.collection(FirestoreSchema.accounts).doc('2').set({
        AppStrings.fullName: 'Sara Mohamed',
        'firstName': 'Ali',  // ← firstName يطابق لكن fullName لا
      });

      final result = await dataSource.getDataSearch(query: 'Ali');

      expect(result.docs.length, 1);
      expect(result.docs.first.id, '1');
    });

    test('returns empty snapshot when collection is empty', () async {
      final result = await dataSource.getDataSearch(query: 'Ali');

      expect(result.docs, isEmpty);
    });
  });
}