import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:social_app/models/user_model.dart';

import '../shared/componentes/public_components.dart';

class NotificationsModel extends UserModel {
  final String userAction;
  final String iconName;
  final String postId;
  final String docId;
  final String friendId;

  NotificationsModel({
    super.userName,
    super.userImage,
    super.dateTime,
    required super.userId,
    required this.userAction,
    required this.iconName,
    required this.friendId,
    required this.postId,
    required this.docId
  });

  NotificationsModel.empty()
      : userAction = '',
        iconName = '',
        docId = '',
        postId = '',
        friendId = '';


  factory NotificationsModel.fromJson(Map<String, dynamic> json) {
    return NotificationsModel(
      userId: json['userId']  ?? '',
      iconName: json['iconName']  ?? '',
      userImage: json['userImage']  ?? '',
      userAction: json['userAction']  ?? '',
      userName: json['userName']  ?? '',
      friendId: json['friendId']  ?? '',
      postId: json['postId'] ?? '',
      docId: json['docId'] ?? ''
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      'docId': docId,
      'userId': userId,
      'postId': postId,
      'friendId': friendId,
      'iconName': iconName,
      'userAction': userAction,
      'dateTime': dateTime
    };
  }


  Icon get icon {
    switch (iconName) {
      case 'thumb_up':
        return const Icon(Icons.thumb_up,size: 15.0,);
      case 'mode_comment':
        return const Icon(Icons.mode_comment, size: 15.0,);
      case 'share':
        return const Icon(Icons.share, size: 15.0,);
      default:
        return const Icon(
            Icons.error);
    }
  }
}


class NotificationsData {
  NotificationsModel notificationsModel;

  NotificationsData({required this.notificationsModel});

  static Future<NotificationsData> fromDocumentSnapshot(DocumentSnapshot doc1, DocumentSnapshot doc2) async {
    try {
      if (!doc1.exists || !doc2.exists) {
        print('Document missing - Doc1 exists: ${doc1.exists}, Doc2 exists: ${doc2.exists}');
        return NotificationsData(notificationsModel: NotificationsModel.empty());
      }

      final userAccount = await getAccountMap(userDoc: doc1);
      final userNotifications = doc2.data();

      // Debug logging
      print('User Account Data: $userAccount');
      print('User Notifications Data: $userNotifications');

      if (userAccount == null || userNotifications == null) {
        print('Null data - Doc1: ${doc1.id}, Doc2: ${doc2.id}');
        return NotificationsData(notificationsModel: NotificationsModel.empty());
      }

      final userAccountMap = userAccount as Map<String, dynamic>;
      final userNotificationsMap = userNotifications as Map<String, dynamic>;

      // Validate required fields
      if (!userAccountMap.containsKey('userImage') ||
          !userAccountMap.containsKey('firstName') ||
          !userAccountMap.containsKey('lastName')) {
        print('Missing required fields in user account');
        return NotificationsData(notificationsModel: NotificationsModel.empty());
      }

      // Merge data
      final mergedData = Map<String, dynamic>.from(userNotificationsMap);
      mergedData['userImage'] = userAccountMap['userImage'];
      mergedData['userName'] = '${userAccountMap['fullName']}';

      print('Merged Data: $mergedData');

      return NotificationsData(
        notificationsModel: NotificationsModel.fromJson(mergedData),
      );
    } catch (e, stackTrace) {
      print('Error creating NotificationsData: $e');
      print('Stack trace: $stackTrace');
      return NotificationsData(notificationsModel: NotificationsModel.empty());
    }
  }
}

