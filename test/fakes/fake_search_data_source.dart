import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:social_app/features/search/domain/data_sources/search_data_source.dart';


class FakeSearchDataSource implements SearchDataSource {
  // ===== getSupCollection =====
  QuerySnapshot<Map<String, dynamic>>? collectionToReturn;
  int getSupCollectionCallCount = 0;
  String? lastGetSupCollectionPath;

  @override
  Future<QuerySnapshot<Map<String, dynamic>>> getSupCollection({
    required String collectionPath,
  }) async {
    getSupCollectionCallCount++;
    lastGetSupCollectionPath = collectionPath;
    return collectionToReturn!;
  }

  // ===== getDataSearch =====
  QuerySnapshot<Map<String, dynamic>>? searchResult;
  int getDataSearchCallCount = 0;
  String? lastQuery;

  @override
  Future<QuerySnapshot<Map<String, dynamic>>> getDataSearch({
    required String query,
  }) async {
    getDataSearchCallCount++;
    lastQuery = query;
    return searchResult!;
  }

  // باقي دوال FirestoreService — noSuchMethod
  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError(
        'FakeSearchDataSource.${invocation.memberName} not stubbed',
      );
}