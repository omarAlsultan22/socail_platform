import 'package:flutter/material.dart';
import '../../../models/user_model.dart';
import '../../../modules/main_screen/cubit.dart';
import '../../../shared/constants/user_details.dart';
import '../../../modules/profile_screen/user_profile_screen.dart';
import '../../../shared/componentes/public_components.dart';


class LikesModel extends StatelessWidget {
  final UserModel like;
  final VoidCallback? onPressed;
  final String? userId;

  const LikesModel({
    required this.like,
    this.onPressed,
    this.userId,
    super.key,
  });

  void _handleUserProfile(BuildContext context, MainLayoutCubit cubit) {
    if (like.userId == null) return;

    if (userId != null && userId == like.userId) {
      Navigator.of(context).popUntil((route) =>
      route.settings.name == '/user_profile');
    }
    else if (like.userId != UserDetails.uId) {
      navigator(context, UserProfile(userId: like.userId!));
    }
    else {
      Navigator.of(context).popUntil((route) => route.isFirst);
      cubit.changeIndexScreen(4);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cubit = MainLayoutCubit.get(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: InkWell(
        onTap: () => _handleUserProfile(context, cubit),
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
                    backgroundImage: like.userImage != null
                        ? NetworkImage(like.userImage!)
                        : const AssetImage(
                        'assets/default_avatar.png') as ImageProvider,
                  ),
                ),
                const SizedBox(width: 8.0),
                Text(
                  like.userName ?? 'Unknown User',
                  style: const TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),

            // Friend Button Section
            if (like.isFriend == true && onPressed != null)
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