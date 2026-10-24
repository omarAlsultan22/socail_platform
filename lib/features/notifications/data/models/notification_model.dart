import 'package:flutter/material.dart';
import 'package:social_app/core/constants/app_strings.dart';
import 'package:social_app/core/data/models/my_model.dart';


class NotificationsModel extends MyModel {
  final String userAction;
  final String iconName;
  final String postId;
  final String docId;
  final String friendId;

  NotificationsModel({
    super.myName,
    super.myImageUrl,
    super.myDateTime,
    required super.myId,
    required this.userAction,
    required this.iconName,
    required this.friendId,
    required this.postId,
    required this.docId
  });

  NotificationsModel.empty()
      : userAction = AppStrings.empty,
        iconName = AppStrings.empty,
        docId = AppStrings.empty,
        postId = AppStrings.empty,
        friendId = AppStrings.empty;


  factory NotificationsModel.fromJson(Map<String, dynamic> json) {
    return NotificationsModel(
      myId: json['userId']  ?? AppStrings.empty,
      iconName: json['iconName']  ?? AppStrings.empty,
      myImageUrl: json['userImage']  ?? AppStrings.empty,
      userAction: json['userAction']  ?? AppStrings.empty,
      myName: json['userName']  ?? AppStrings.empty,
      friendId: json['friendId']  ?? AppStrings.empty,
      postId: json['postId'] ?? AppStrings.empty,
      docId: json['docId'] ?? AppStrings.empty
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'docId': docId,
      'userId': myId,
      'postId': postId,
      'friendId': friendId,
      'iconName': iconName,
      'userAction': userAction,
      'dateTime': myDateTime
    };
  }

  Icon get icon {
    switch (iconName) {
      case 'thumb_up':
        return const Icon(Icons.thumb_up,size: 15.0);
      case 'mode_comment':
        return const Icon(Icons.mode_comment, size: 15.0);
      case 'share':
        return const Icon(Icons.share, size: 15.0);
      default:
        return const Icon(
            Icons.error);
    }
  }
}

