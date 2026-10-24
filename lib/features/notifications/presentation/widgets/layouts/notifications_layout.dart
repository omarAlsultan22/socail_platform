import 'package:flutter/material.dart';
import 'package:social_app/core/constants/app_sizes.dart';
import 'package:social_app/core/constants/app_paddings.dart';
import 'package:social_app/core/constants/app_text_styles.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../post_detail/presentation/screens/post_detail_screen.dart';
import 'package:social_app/core/presentation/widgets/navigation/navigator.dart';
import 'package:social_app/features/notifications/data/models/notification_model.dart';


class NotificationsLayout extends StatelessWidget {
  final NotificationsModel notificationsModel;

  const NotificationsLayout({
    super.key,
    required this.notificationsModel
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        BuildNavigator.build(
            context: context,
            link: PostDetailScreen(notificationsModel: notificationsModel,
            )
        );
      },
      child: Padding(
        padding: AppPaddings.onlyLeft10,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Stack(
              alignment: AlignmentDirectional.bottomEnd,
              children: [
                SizedBox(
                  width: AppSizes.xl,
                  height: AppSizes.xl,
                  child: ClipOval(
                    child: CachedNetworkImage(
                      fit: BoxFit.cover,
                      imageUrl: notificationsModel.myImageUrl,
                    ),
                  ),
                ),
                notificationsModel.icon
              ],
            ),
            Padding(
              padding: AppPaddings.xs,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    notificationsModel.myName,
                    style: AppTextStyles.boldLarge,
                  ),
                  Text(
                    notificationsModel.userAction,
                    // Fallback for null action
                    style: AppTextStyles.bodyLarge,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}