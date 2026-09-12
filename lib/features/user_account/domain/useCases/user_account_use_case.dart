import '../repositories/user_account_repository.dart';
import 'package:social_app/core/services/session_service.dart';
import 'package:social_app/core/data/models/account_model.dart';


class UserAccountUseCase {
  final UserAccountRepository _repository;
  final SessionService _sessionService;

  UserAccountUseCase({
    required UserAccountRepository repository,
    required SessionService sessionService
  })
      : _repository = repository,
        _sessionService = sessionService;

  Future<UserAccount> executeGetAccount() async {
    try {
      return await _repository.getAccount(_sessionService.currentUid);
    }
    catch (e) {
      rethrow;
    }
  }

  Future<void> executeUpdateAccount({
    required String firstName,
    required String lastName,
  }) async {
    final userAccount = UserAccount(
        firstName: firstName,
        lastName: lastName,
        fullName: '$firstName $lastName',
        userId: _sessionService.currentUid
    );
    try {
      await _repository.updateAccount(
        userAccount: userAccount,
      );
    }
    catch (e) {
      rethrow;
    }
  }
}
