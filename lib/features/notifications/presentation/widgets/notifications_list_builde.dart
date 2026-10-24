import 'package:flutter/material.dart';
import 'package:social_app/core/constants/app_colors.dart';
import 'package:social_app/core/constants/app_strings.dart';
import 'package:social_app/core/constants/app_paddings.dart';
import 'package:social_app/core/constants/app_text_styles.dart';
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
        Padding(
          padding: AppPaddings.xs,
          child: Text(
            'Notifications',
            style: AppTextStyles.boldXLarge,
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
              Center(
                child: Text(
                  AppStrings.noNotifications,
                  style: AppTextStyles.bodyXLarge.copyWith(color: AppColors.grey),
                ),
              ),
        ),
      ],
    );
  }
}