import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:social_app/models/user_model.dart';


class CommentModel extends UserModel{
  late final String userAction;
  late int? likesNumber;
  final List<UserModel>? likesList;
  final String docId;
  final String postId;
  final bool isActive;

  CommentModel({
    super.userName,
    super.userImage,
    super.dateTime,
    this.likesList,
    this.likesNumber,
    required this.postId,
    required this.docId,
    this.isActive = false,
    required super.userId,
    required this.userAction,
  });

  factory CommentModel.fromJson(Map<String, dynamic> json) {
    return CommentModel(
      docId: json['docUid']?.toString() ?? '',
      userId: json['userId']?.toString() ?? '',
      userName: json['fullName']?.toString() ?? '',
      userImage: json['userImage']?.toString() ?? '',
      userAction: json['userAction']?.toString() ?? '',
      postId: json['postId']?.toString() ?? '',
      likesNumber: json['likesNumber'] ?? 0,
      isActive: json['isActive'] ?? false,
      dateTime: _convertToDateTime(json['dateTime'] ?? '')
    );
  }


  @override
  Map<String, dynamic> toMap() {
    return {
      'docUid': docId,
      'userId': userId,
      'userAction': userAction,
      'dateTime': dateTime,
      'postId': postId,
      'isActive': isActive
    };
  }

  static DateTime _convertToDateTime(dynamic timestamp) {
    if (timestamp == null) return DateTime.now();
    if (timestamp is Timestamp) return timestamp.toDate();
    if (timestamp is DateTime) return timestamp;
    return DateTime.now();
  }
}

