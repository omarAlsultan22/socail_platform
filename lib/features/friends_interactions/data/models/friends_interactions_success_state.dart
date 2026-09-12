import '../../../../core/data/models/user_model.dart';
import 'package:social_app/core/presentation/states/base/main_loaded_state.dart';


class FriendsInteractionsSuccessState extends LoadedState {
  final List<UserModel> friendsRequestsList;
  final List<UserModel> friendsSuggestsList;

  const FriendsInteractionsSuccessState({
    required this.friendsRequestsList,
    required this.friendsSuggestsList,
  });
}