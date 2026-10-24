import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/data_sources/search_data_source.dart';
import 'package:social_app/core/constants/app_strings.dart';
import 'package:social_app/core/data/data_sources/remote/firestore/firestore_service_impl.dart';


class SearchDataSourceImpl extends FirestoreServiceImpl implements SearchDataSource {

  @override
  Future<QuerySnapshot<Map<String, dynamic>>> getDataSearch({
    required String query
  }) async {
    return await firestore
        .collection(AppStrings.accounts)
        .where(AppStrings.fullName, isGreaterThanOrEqualTo: query)
        .where(AppStrings.fullName, isLessThanOrEqualTo: '$query\uf8ff')
        .get().timeout(duration);
  }
}