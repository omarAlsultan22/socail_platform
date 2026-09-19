import 'package:flutter/material.dart';
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
        padding: const EdgeInsets.only(left: 10.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Stack(
              alignment: AlignmentDirectional.bottomEnd,
              children: [
                SizedBox(
                  width: 50.0,
                  height: 50.0,
                  child: ClipOval(
                    child: CachedNetworkImage(
                      fit: BoxFit.cover,
                      imageUrl: notificationsModel.userImage ?? '',
                    ),
                  ),
                ),
                notificationsModel.icon
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    notificationsModel.userName ?? 'Unknown User',
                    // Fallback for null name
                    style: const TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    notificationsModel.userAction,
                    // Fallback for null action
                    style: const TextStyle(fontSize: 15),
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





