import '../../../../core/data/models/user_model.dart';
import '../repositories/search_repository.dart';


class SearchUseCase {
  final SearchRepository _repository;

  SearchUseCase({
    required SearchRepository repository,
  })
      :_repository = repository;

  Future<List<UserModel>> execute({
    required String query
  }) async {
    try {
      final List<UserModel> searchResults = [];
      final userAccountSnapshot = await _repository.getDataSearch(query: query.toLowerCase());
      for (final userAccount in userAccountSnapshot.docs) {
        final userData = await getAccountMap(userDoc: userAccount);
        final fullName = userData['fullName']?.toString().toLowerCase() ?? '';

        if (fullName.contains(query)) {
          searchResults.add(UserModel.fromJson(userData));
        }
      }
      return searchResults;
    }
    catch (e) {
      rethrow;
    }
  }
}

