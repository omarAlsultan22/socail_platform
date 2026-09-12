import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:social_app/core/constants/app_durations.dart';
import 'package:social_app/core/data/data_sources/remote/firestore/firestore_base_service.dart';


class FirestoreSearchService extends FirestoreBaseService{
  static final _duration = AppDurations.seconds;
  static final _firestore = FirebaseFirestore.instance;

  Future<QuerySnapshot<Map<String, dynamic>>> getDataSearch({
    required String query
  }) async {
    return await _firestore
        .collection('accounts')
        .where('fullName', isGreaterThanOrEqualTo: query)
        .where('fullName', isLessThanOrEqualTo: '$query\uf8ff')
        .get().timeout(_duration);
  }
}