import '../../../../core/data/models/my_model.dart';
import '../../../../core/services/session_service.dart';
import '../../../../core/services/user_account_service.dart';


class UserDetailsUseCase {
  final SessionService _sessionService;
  final UserAccountService _userAccountService;

  UserDetailsUseCase({
    required SessionService sessionService,
    required UserAccountService userAccountService,
  })
      : _sessionService = sessionService,
        _userAccountService = userAccountService;

  Future<MyModel> executeGetUserDetails() async {
    final userModel = await _userAccountService.getUserModelData(
        id: _sessionService.currentUid
    );
    return userModel;
  }
}