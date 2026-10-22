import '../repositories/search_repository.dart';
import '../../../../core/data/models/my_model.dart';
import '../../../../core/services/domain/i_user_account_service.dart';


class SearchUseCase {
  final SearchRepository _repository;
  final IUserAccountService _userAccountService;

  SearchUseCase({
    required SearchRepository repository,
    required IUserAccountService userAccountService
  })
      :_repository = repository,
        _userAccountService = userAccountService;

  Future<List<MyModel>> execute({
    required String query
  }) async {
    final List<MyModel> searchResults = [];
    final userAccountSnapshot = await _repository.getDataSearch(
        query: query.toLowerCase());
    if (userAccountSnapshot == null) {
      return [];
    }
    for (final userAccount in userAccountSnapshot.docs) {
      final userData = await _userAccountService.getAccountMap(
          userDoc: userAccount);
      final fullName = userData['fullName']?.toString().toLowerCase() ?? '';

      if (fullName.contains(query)) {
        searchResults.add(MyModel.fromJson(userData));
      }
    }
    return searchResults;
  }
}

