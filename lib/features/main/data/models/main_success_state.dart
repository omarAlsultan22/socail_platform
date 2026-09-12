import '../../../../core/data/models/user_model.dart';
import 'package:social_app/core/presentation/states/base/main_loaded_state.dart';


class MainSuccessState extends LoadedState {
  final int currentScreenIndex;
  final Set<String> messagesDocIds;
  final List<UserModel> suggestsList;
  final Set<String> notificationsDocIds;
  final Set<String> friendRequestsDocIds;

  const MainSuccessState({
    required this.suggestsList,
    required this.messagesDocIds,
    required this.currentScreenIndex,
    required this.notificationsDocIds,
    required this.friendRequestsDocIds,
  });
}