import 'package:flutter/cupertino.dart';
import 'package:social_app/core/services/data/session_service.dart';
import '../presentation/widgets/navigation/navigator.dart';
import '../../features/main/presentation/cubits/main_cubit.dart';
import '../../features/profile/presentation/screens/user_profile_screen.dart';


class FriendProfileNavigator {
  static void handle({
    String? userId,
    required String modelUserId,
    required BuildContext context,
    required SessionService sessionService,
  }) {
    if (modelUserId.isEmpty) return;

    if (userId != null) {
      Navigator.of(context).popUntil(
            (route) => route.settings.name == '/friend_profile',
      );
    } else if (modelUserId != sessionService.currentUid) {
      BuildNavigator.build(
        context: context,
        link: UserProfileScreen(friendId: modelUserId),
      );
    } else {
      MainCubit.get(context).changeIndexScreen(3);
      Navigator.of(context).popUntil((route) => route.isFirst);
    }
  }
}