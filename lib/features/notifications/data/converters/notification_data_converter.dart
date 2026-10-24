import 'package:flutter/cupertino.dart';
import '../models/notification_model.dart';
import '../../../../core/di/service _locator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:social_app/core/constants/app_strings.dart';
import '../../../../core/services/domain/i_user_account_service.dart';


class NotificationsDataConverter {
  final NotificationsModel notificationsModel;
  final IUserAccountService userAccountService;

  const NotificationsDataConverter({
    required this.userAccountService,
    required this.notificationsModel
  });

  static final _userAccountService = sl<IUserAccountService>();

  static final _notificationModel = NotificationsDataConverter(
      userAccountService: _userAccountService,
      notificationsModel: NotificationsModel.empty()
  );

  static Future<NotificationsDataConverter> fromDocumentSnapshot({
    required DocumentSnapshot userAccountDoc,
    required DocumentSnapshot notificationDoc,
  }) async {
    try {
      if (!userAccountDoc.exists || !notificationDoc.exists) {
        debugPrint(
            'Document missing - Doc1 exists: ${userAccountDoc.exists}, Doc2 exists: ${notificationDoc
                .exists}');
        return _notificationModel;
      }

      final userAccount = await _userAccountService.getAccountMap(userDoc: userAccountDoc);
      final userNotifications = notificationDoc.data();

      // Debug logging
      debugPrint('User Account Data: $userAccount');
      debugPrint('User Notifications Data: $userNotifications');

      if (userAccount.isEmpty || userNotifications == null) {
        debugPrint('Null data - Doc1: ${userAccountDoc.id}, Doc2: ${notificationDoc.id}');
        return _notificationModel;
      }

      final userAccountMap = userAccount;
      final userNotificationsMap = userNotifications as Map<String, dynamic>;

      // Validate required fields
      if (!userAccountMap.containsKey(AppStrings.userImage) ||
          !userAccountMap.containsKey(AppStrings.firstName) ||
          !userAccountMap.containsKey(AppStrings.lastName)) {
        debugPrint('Missing required fields in user account');
        return _notificationModel;
      }

      // Merge data
      final mergedData = Map<String, dynamic>.from(userNotificationsMap);
      mergedData[AppStrings.userImage] = userAccountMap[AppStrings.userImage];
      mergedData[AppStrings.userName] = '${userAccountMap[AppStrings.fullName]}';

      debugPrint('Merged Data: $mergedData');

      return _notificationModel;
    } catch (e, stackTrace) {
      debugPrint('Error creating NotificationsData: $e');
      debugPrint('Stack trace: $stackTrace');
      return _notificationModel;
    }
  }
}