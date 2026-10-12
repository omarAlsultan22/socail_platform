import '../../../../core/data/models/message_result.dart';
import 'package:social_app/core/data/models/user_info_model.dart';
import 'package:social_app/core/presentation/states/base/main_loaded_state.dart';


class ProfileSuccessState extends LoadedState {
  // ✅ State variables
  final int currentButtonScreen;

  // ✅ Friendship Button
  final String friendshipButtonKey;

  // ✅ State message
  final MessageResult messageResult;

  // ✅ User Info Data
  final UserInfoModel userInfoModel;

  const ProfileSuccessState({
    required this.messageResult,
    required this.userInfoModel,
    required this.currentButtonScreen,
    required this.friendshipButtonKey,
  });
}