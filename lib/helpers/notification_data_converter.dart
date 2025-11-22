import '../models/notification_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../shared/componentes/public_components.dart';


class NotificationsDataConverter {
  NotificationsModel notificationsModel;

  NotificationsDataConverter({required this.notificationsModel});

  static Future<NotificationsDataConverter> fromDocumentSnapshot(
      DocumentSnapshot doc1, DocumentSnapshot doc2) async {
    try {
      if (!doc1.exists || !doc2.exists) {
        print(
            'Document missing - Doc1 exists: ${doc1.exists}, Doc2 exists: ${doc2
                .exists}');
        return NotificationsDataConverter(
            notificationsModel: NotificationsModel.empty());
      }

      final userAccount = await getAccountMap(userDoc: doc1);
      final userNotifications = doc2.data();

      // Debug logging
      print('User Account Data: $userAccount');
      print('User Notifications Data: $userNotifications');

      if (userAccount == null || userNotifications == null) {
        print('Null data - Doc1: ${doc1.id}, Doc2: ${doc2.id}');
        return NotificationsDataConverter(
            notificationsModel: NotificationsModel.empty());
      }

      final userAccountMap = userAccount as Map<String, dynamic>;
      final userNotificationsMap = userNotifications as Map<String, dynamic>;

      // Validate required fields
      if (!userAccountMap.containsKey('userImage') ||
          !userAccountMap.containsKey('firstName') ||
          !userAccountMap.containsKey('lastName')) {
        print('Missing required fields in user account');
        return NotificationsDataConverter(
            notificationsModel: NotificationsModel.empty());
      }

      // Merge data
      final mergedData = Map<String, dynamic>.from(userNotificationsMap);
      mergedData['userImage'] = userAccountMap['userImage'];
      mergedData['userName'] = '${userAccountMap['fullName']}';

      print('Merged Data: $mergedData');

      return NotificationsDataConverter(
        notificationsModel: NotificationsModel.fromJson(mergedData),
      );
    } catch (e, stackTrace) {
      print('Error creating NotificationsData: $e');
      print('Stack trace: $stackTrace');
      return NotificationsDataConverter(
          notificationsModel: NotificationsModel.empty());
    }
  }
}