import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:social_app/core/data/models/my_model.dart';


class CommentModel extends MyModel{
  final String docId;
  final String postId;
  final bool hasMeLiked;
  late int? likesNumber;
  late final String? userAction;
  final List<MyModel>? likesList;

  CommentModel({
    super.myName,
    this.likesList,
    super.myDateTime,
    super.myImageUrl,
    this.likesNumber,
    required super.myId,
    required this.docId,
    required this.postId,
    this.hasMeLiked = false,
    required this.userAction,
  });

  factory CommentModel.fromJson(Map<String, dynamic> json) {
    return CommentModel(
      docId: json['docUid']?.toString() ?? '',
      myId: json['userId']?.toString() ?? '',
      myName: json['fullName']?.toString() ?? '',
      myImageUrl: json['userImage']?.toString() ?? '',
      userAction: json['userAction']?.toString() ?? '',
      postId: json['postId']?.toString() ?? '',
      likesNumber: json['likesNumber'] ?? 0,
      hasMeLiked: json['hasMeLiked'] ?? false,
      myDateTime: _convertToDateTime(json['dateTime'] ?? '')
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'userId': myId,
      'docUid': docId,
      'postId': postId,
      'dateTime': myDateTime,
      'userAction': userAction,
    };
  }

  static DateTime _convertToDateTime(dynamic timestamp) {
    if (timestamp == null) return DateTime.now();
    if (timestamp is Timestamp) return timestamp.toDate();
    if (timestamp is DateTime) return timestamp;
    return DateTime.now();
  }
}

