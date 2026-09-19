import 'package:flutter/material.dart';
import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:social_app/features/notifications/data/models/notification_model.dart';
import 'package:social_app/features/notifications/presentation/widgets/layouts/notifications_layout.dart';


class NotificationListBuilder extends StatelessWidget {
  final List<NotificationsModel> notificationData;

  const NotificationListBuilder({super.key, required this.notificationData});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.all(8.0),
          child: Text(
            'Notifications',
            style: TextStyle(
              fontSize: 20.0,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        ConditionalBuilder(
          condition: notificationData.isNotEmpty,
          builder: (context) =>
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) =>
                    NotificationsLayout(
                        notificationsModel: notificationData[index]
                    ),
                itemCount: notificationData.length,
                key: const Key('notification_list'), // Add a key
              ),
          fallback: (context) =>
          const Center(
            child: Text(
              "No notifications available",
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ),
        ),
      ],
    );
  }
}





