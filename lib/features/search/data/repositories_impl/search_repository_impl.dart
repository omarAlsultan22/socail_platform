import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/repositories/search_repository.dart';
import '../../domain/data_sources/search_data_source.dart';
import 'package:social_app/core/constants/app_strings.dart';


class SearchRepositoryImpl implements SearchRepository {
  final SearchDataSource _dataSource;

  SearchRepositoryImpl({
    required SearchDataSource dataSource
  })
      : _dataSource = dataSource;


  @override
  Future<QuerySnapshot<Map<String, dynamic>>?> getDataSearch({
    required String query
  }) async {
    final usersSnapshot = await _dataSource.getSupCollection(
        collectionPath: AppStrings.users);

    await Future.wait(
        usersSnapshot.docs.map((userDoc) async {
          return await _dataSource.getDataSearch(query: query);
        })
    );
    return null;
  }
}