import '../../../../core/data/models/user_model.dart';
import 'package:social_app/core/presentation/states/base/main_loaded_state.dart';


class FriendshipSuccessState extends LoadedState {
  final List<UserModel> friendsRequestsList;
  final List<UserModel> friendsSuggestsList;

  const FriendshipSuccessState({
    required this.friendsRequestsList,
    required this.friendsSuggestsList,
  });
}