import 'package:social_app/models/user_model.dart';
import 'package:flutter/material.dart';


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

