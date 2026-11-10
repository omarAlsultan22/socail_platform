import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:social_app/features/search/domain/repositories/search_repository.dart';


class FakeSearchRepository implements SearchRepository {
  QuerySnapshot<Map<String, dynamic>>? searchResult;
  Object? searchError;
  int getDataSearchCallCount = 0;
  String? lastQuery;

  @override
  Future<QuerySnapshot<Map<String, dynamic>>?> getDataSearch({
    required String query,
  }) async {
    getDataSearchCallCount++;
    lastQuery = query;
    if (searchError != null) throw searchError!;
    return searchResult;
  }
}