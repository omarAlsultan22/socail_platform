import 'package:flutter/material.dart';
import '../../../di/service _locator.dart';
import '../../../../../core/data/models/my_model.dart';
import 'package:social_app/core/services/data/session_service.dart';
import '../friend_button.dart';
import 'package:social_app/core/helpers/friend_profile_navigator.dart';


class UserRowLayout extends StatelessWidget {
  final String? userId;
  final MyModel userRow;
  final VoidCallback? onPressed;

  const UserRowLayout({
    super.key,
    this.userId,
    this.onPressed,
    required this.userRow,
  });


  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: InkWell(
        onTap: () =>
            FriendProfileNavigator.handle(
                userId: userId,
                context: context,
                modelUserId: userRow.myId,
                sessionService: sl<SessionService>()
            ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // User Info Section
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: CircleAvatar(
                    radius: 25.0,
                    backgroundImage: userRow.myImageUrl != null
                        ? NetworkImage(userRow.myImageUrl!)
                        : const AssetImage(
                        'assets/default_avatar.png') as ImageProvider,
                  ),
                ),
                const SizedBox(width: 8.0),
                Text(
                  userRow.myName ?? 'Unknown User',
                  style: const TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            // Friend Button Section
            if (userRow.isFriend == true && onPressed != null)
              Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: FriendButton(
                  buttonName: 'Add Friend',
                  backgroundColor: Colors.blue.shade900,
                  textColor: Colors.white,
                  onPressed: onPressed!,
                ),
              ),
          ],
        ),
      ),
    );
  }
}