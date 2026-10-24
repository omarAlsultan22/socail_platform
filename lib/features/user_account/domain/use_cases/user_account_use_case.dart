import '../repositories/user_account_repository.dart';
import 'package:social_app/core/data/models/user_account.dart';
import 'package:social_app/core/services/data/session_service.dart';


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
    return await _repository.getAccount(_sessionService.currentUid);
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
    await _repository.updateAccount(
      userAccount: userAccount,
    );
  }
}
