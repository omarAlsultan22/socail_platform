import '../../../../core/data/models/my_model.dart';
import 'package:social_app/core/presentation/states/base/main_loaded_state.dart';


class FriendshipSuccessState extends LoadedState {
  final List<MyModel> friendsRequestsList;
  final List<MyModel> friendsSuggestsList;

  const FriendshipSuccessState({
    required this.friendsRequestsList,
    required this.friendsSuggestsList,
  });
}