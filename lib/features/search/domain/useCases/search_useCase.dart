import '../repositories/search_repository.dart';
import '../../../../core/data/models/user_model.dart';
import 'package:social_app/core/services/user_account_service.dart';


class SearchUseCase {
  final SearchRepository _repository;
  final UserAccountService _userAccountService;

  SearchUseCase({
    required SearchRepository repository,
    required UserAccountService userAccountService
  })
      :_repository = repository,
        _userAccountService = userAccountService;

  Future<List<UserModel>> execute({
    required String query
  }) async {
    try {
      final List<UserModel> searchResults = [];
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

