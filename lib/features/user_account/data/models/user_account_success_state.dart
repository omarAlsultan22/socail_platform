import '../../../../core/data/models/account_model.dart';
import '../../../../core/data/models/message_result.dart';
import 'package:social_app/core/presentation/states/base/main_loaded_state.dart';


class UserAccountSuccessState extends LoadedState {
  final UserAccount userAccount;
  final MessageResult messageResult;

  const UserAccountSuccessState({
    required this.userAccount,
    required this.messageResult
  });
}