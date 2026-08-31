import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/repositories/search_repository.dart';
import 'package:social_app/core/data/data_sources/remote/firestore/firestore_base_service.dart';


class FirestoreSearchRepository implements SearchRepository {
  final FirestoreBaseService _repository;

  FirestoreSearchRepository({
    required FirestoreBaseService repository
  })
      : _repository = repository;


  @override
  Future<QuerySnapshot<Map<String, dynamic>>> getDataSearch({
    required String query
  }) async {
    try {
      final firebase = FirebaseFirestore.instance;/

      final usersSnapshot = await _repository.getSupCollection(
          collectionPath: 'users');

      await Future.wait(usersSnapshot.docs.map((userDoc) async {
    final userAccountSnapshot = await firebase
            .collection('accounts')
            .where('fullName', isGreaterThanOrEqualTo: query)
            .where('fullName', isLessThanOrEqualTo: '$query\uf8ff')
            .get();
      })
      );
    } catch (e) {
      rethrow;
    }
  }

}