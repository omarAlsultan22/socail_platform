import '../../../../core/data/models/message_result.dart';
import 'package:social_app/core/data/models/profile_info_model.dart';
import 'package:social_app/core/presentation/states/base/main_loaded_state.dart';


class UserInfoSuccessState extends LoadedState {
  final MessageResult messageResult;
  final ProfileInfoModel profileInfoModel;

  const UserInfoSuccessState({
    required this.messageResult,
    required this.profileInfoModel
  });
}