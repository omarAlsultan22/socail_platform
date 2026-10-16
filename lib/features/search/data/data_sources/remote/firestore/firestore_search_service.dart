import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:social_app/core/constants/app_durations.dart';
import 'package:social_app/core/data/data_sources/remote/firestore/firestore_base_service.dart';


class FirestoreSearchService extends FirestoreBaseService{
  Future<QuerySnapshot<Map<String, dynamic>>> getDataSearch({
    required String query
  }) async {
    return await firestore
        .collection('accounts')
        .where('fullName', isGreaterThanOrEqualTo: query)
        .where('fullName', isLessThanOrEqualTo: '$query\uf8ff')
        .get().timeout(duration);
  }
}