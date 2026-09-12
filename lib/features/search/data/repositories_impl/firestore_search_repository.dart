import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/repositories/search_repository.dart';
import '../data_sources/remote/firestore/firestore_search_service.dart';


class FirestoreSearchRepository implements SearchRepository {
  final FirestoreSearchService _repository;

  FirestoreSearchRepository({
    required FirestoreSearchService repository
  })
      : _repository = repository;


  @override
  Future<QuerySnapshot<Map<String, dynamic>>?> getDataSearch({
    required String query
  }) async {
    try {
      final usersSnapshot = await _repository.getSupCollection(
          collectionPath: 'users');

      await Future.wait(
          usersSnapshot.docs.map((userDoc) async {
            return await _repository.getDataSearch(query: query);
          })
      );
      return null;
    } catch (e) {
      rethrow;
    }
  }
}