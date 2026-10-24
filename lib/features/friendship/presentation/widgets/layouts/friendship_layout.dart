import 'package:flutter/material.dart';
import '../../../domain/enums/friendship_type.dart';
import '../../../../../core/data/models/my_model.dart';
import 'package:social_app/core/constants/app_sizes.dart';
import 'package:social_app/core/constants/app_spaces.dart';
import 'package:social_app/core/constants/app_colors.dart';
import 'package:social_app/core/constants/app_paddings.dart';
import 'package:social_app/core/constants/app_text_styles.dart';
import '../../../../profile/presentation/screens/user_profile_screen.dart';
import '../../../../../core/presentation/widgets/navigation/navigator.dart';


class FriendshipLayout extends StatelessWidget {
  final bool isActive;
  final FriendshipType friendshipType;
  final void Function(int) refuseButton;
  final void Function (int) acceptButton;
  final List<MyModel> notificationData;

  const FriendshipLayout({
    super.key,
    required this.isActive,
    required this.friendshipType,
    required this.notificationData,
    required this.acceptButton,
    required this.refuseButton,
  });

  Widget _friendRequestItem({
    required MyModel userModel,
    required BuildContext context,
    required FriendshipType labels,
    required VoidCallback acceptButton,
    required VoidCallback refuseButton
  }) {
    return InkWell(
      onTap: () {
        BuildNavigator.build(
            context: context,
            link: UserProfileScreen(friendId: userModel.myId));
      },
      child: Padding(
        padding: AppPaddings.onlyLeft10,
        child: Row(
          children: [
            SizedBox(
              width: AppSizes.xl,
              height: AppSizes.xl,
              child: ClipOval(
                child: Image.network(
                    userModel.myImageUrl,
                    fit: BoxFit.cover
                ),
              ),
            ),
            Padding(
              padding: AppPaddings.xs,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    userModel.myName,
                    style: AppTextStyles.boldLarge,
                  ),
                  Row(
                    children: [
                      _buildActionButton(
                        onPressed: acceptButton,
                        label: labels.acceptLabel,
                        color: AppColors.primaryBlue,
                        textColor: AppColors.white,
                      ),
                      AppSpaces.horizontal_10,
                      _buildActionButton(
                        onPressed: refuseButton,
                        label: labels.refuseLabel,
                        color: AppColors.grey,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required VoidCallback onPressed,
    required String label,
    required Color color,
    Color? textColor,
  }) {
    return MaterialButton(
      onPressed: onPressed,
      color: color,
      child: Text(
        label,
        style: TextStyle(
          fontSize: 16.0,
          fontWeight: FontWeight.bold,
          color: textColor,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        notificationData.isNotEmpty ?
        Padding(
            padding: AppPaddings.xs,
            child:
            Text(
              friendshipType.title,
              style: AppTextStyles.boldXLarge,
            )
        ) : SizedBox.shrink(),
        ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemBuilder: (context, index) =>
              _friendRequestItem(
                  userModel: notificationData[index],
                  labels: friendshipType,
                  acceptButton: () => acceptButton(index),
                  refuseButton: () => refuseButton(index),
                  context: context
              ),
          itemCount: notificationData.length,
        ),
      ],
    );
  }
}