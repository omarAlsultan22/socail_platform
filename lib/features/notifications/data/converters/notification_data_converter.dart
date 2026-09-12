import '../models/notification_model.dart';
import '../../../../core/di/service _locator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:social_app/core/services/user_account_service.dart';


class NotificationsDataConverter {
  final UserAccountService userAccountService;
  final NotificationsModel notificationsModel;

  const NotificationsDataConverter({
    required this.notificationsModel,
    required this.userAccountService
  });

  static final _userAccountService = sl<UserAccountService>();

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
        print(
            'Document missing - Doc1 exists: ${userAccountDoc.exists}, Doc2 exists: ${notificationDoc
                .exists}');
        return _notificationModel;
      }

      final userAccount = await _userAccountService.getAccountMap(userDoc: userAccountDoc);
      final userNotifications = notificationDoc.data();

      // Debug logging
      print('User Account Data: $userAccount');
      print('User Notifications Data: $userNotifications');

      if (userAccount.isEmpty || userNotifications == null) {
        print('Null data - Doc1: ${userAccountDoc.id}, Doc2: ${notificationDoc.id}');
        return _notificationModel;
      }

      final userAccountMap = userAccount;
      final userNotificationsMap = userNotifications as Map<String, dynamic>;

      // Validate required fields
      if (!userAccountMap.containsKey('userImage') ||
          !userAccountMap.containsKey('firstName') ||
          !userAccountMap.containsKey('lastName')) {
        print('Missing required fields in user account');
        return _notificationModel;
      }

      // Merge data
      final mergedData = Map<String, dynamic>.from(userNotificationsMap);
      mergedData['userImage'] = userAccountMap['userImage'];
      mergedData['userName'] = '${userAccountMap['fullName']}';

      print('Merged Data: $mergedData');

      return _notificationModel;
    } catch (e, stackTrace) {
      print('Error creating NotificationsData: $e');
      print('Stack trace: $stackTrace');
      return _notificationModel;
    }
  }
}