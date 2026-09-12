import '../../../../core/data/models/user_model.dart';
import '../../../../core/data/models/message_result.dart';
import '../../../../core/presentation/states/base/main_loaded_state.dart';


class  SetupFriendsSuccessState extends LoadedState {
  final int friendsNumber;
  final List<UserModel> friendsList;
  final MessageResult messageResult;

  const SetupFriendsSuccessState({
    required this.friendsNumber,
    required this.friendsList,
    required this.messageResult,
  });
}