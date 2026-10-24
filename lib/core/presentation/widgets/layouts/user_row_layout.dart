import '../friend_button.dart';
import 'package:flutter/material.dart';
import '../../../di/service _locator.dart';
import '../../../../../core/data/models/my_model.dart';
import 'package:social_app/core/constants/app_colors.dart';
import 'package:social_app/core/constants/app_spaces.dart';
import 'package:social_app/core/constants/app_assets.dart';
import 'package:social_app/core/constants/app_strings.dart';
import 'package:social_app/core/constants/app_paddings.dart';
import 'package:social_app/core/constants/app_text_styles.dart';
import 'package:social_app/core/services/data/session_service.dart';
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
      padding: AppPaddings.symmetricVertical8,
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
                  padding: AppPaddings.xs,
                  child: CircleAvatar(
                    radius: 25.0,
                    backgroundImage: !userRow.myImageUrlIsEmpty
                        ? NetworkImage(userRow.myImageUrl)
                        : const AssetImage(
                        AppAssets.defaultAvatar) as ImageProvider,
                  ),
                ),
                AppSpaces.horizontal_8,
                Text(
                  userRow.myName ?? AppStrings.unknownUser,
                  style: AppTextStyles.boldMedium,
                ),
              ],
            ),
            // Friend Button Section
            if (userRow.isFriend == true && onPressed != null)
              Padding(
                padding: AppPaddings.onlyRight8,
                child: FriendButton(
                  buttonName: AppStrings.addFriend,
                  backgroundColor: AppColors.primaryBlue,
                  textColor: AppColors.white,
                  onPressed: onPressed!,
                ),
              ),
          ],
        ),
      ),
    );
  }
}