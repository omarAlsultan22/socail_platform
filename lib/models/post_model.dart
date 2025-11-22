import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:social_app/models/friend_model.dart';
import 'package:social_app/models/user_model.dart';
import 'package:video_player/video_player.dart';
import 'comment_model.dart';
import 'dart:io';


class PostModel extends UserData{
  late String? userText;
  late String? userState;
  late String? docId;
  late String? userPost;
  late String? postType;
  late String? pathType;
  late File? file;
  bool isActive;
  int? likesNumber;
  int? commentsNumber;
  late int? sharesNumber;
  final UserData? friendModel;
  final List<UserModel>? likesList;
  final List<CommentModel>? commentsList;
  VideoPlayerController? videoController;


  PostModel({
    super.userId,
    super.userName,
    super.userImage,
    super.originalDateTime,
    super.friendState,
    super.friendText,
    super.friendId,
    super.friendName,
    super.friendImage,
    super.isOnline,
    this.postType,
    this.pathType,
    this.file,
    this.isActive = false,
    this.sharesNumber,
    this.likesNumber,
    this.commentsNumber,
    this.userState,
    this.docId,
    super.dateTime,
    this.userPost,
    this.userText,
    this.friendModel,
    this.likesList,
    this.commentsList,
    this.videoController
  });



  factory PostModel.fromFirestoreToPost(Map<String, dynamic> json) {
    final isShared = json['postType'] == 'shared';
    return PostModel(
        userId: json['userId'] ?? '',
        userName: json['fullName'] ?? '',
        userImage: json['userImage'] ?? '',
        docId: json['docId'] ?? '',
        userText: json['userText'] ?? '',
        userPost: json['userPost'] ?? '',
        userState: json['userState'] ?? 'public',
        pathType: json['pathType'] ?? '',
        isActive: json['isActive'] ?? '',
        dateTime: _convertToDateTime(json['dateTime'] ?? ''),
        sharesNumber: json['sharesNumber'] ?? 0,
        likesNumber: json['likesNumber'] ?? 0,
        commentsNumber: json['commentsNumber'] ?? 0,
        isOnline: json['isOnline'] ?? false,
        likesList: json['likesList'] ?? [],
        commentsList: json['commentsList'] ?? [],
        friendModel: isShared ?
        UserData(
            friendId: json['friendId'] ?? '',
            friendName: json['friendName'] ?? '',
            friendImage: json['friendImage'] ?? '',
            originalDateTime: _convertToDateTime(json['originalDateTime'] ?? ''),
            friendText: json['friendText'] ?? '',
            friendState: json['friendState'] ?? ''
        ) : UserData()
    );
  }


  factory PostModel.fromFirestoreToStatus(Map<String, dynamic> json) {
    return PostModel(
      userId: json['userId'] ?? '',
      userName: json['fullName'] ?? '',
      userImage: json['userImage'] ?? '',
      docId: json['docId'] ?? '',
      pathType: json['pathType'] ?? '',
      userPost: json['userPost'] ?? '',
      userText: json['userText'] ?? '',
      isOnline: json['isOnline'] ?? false,
      userState: json['userState'] ?? 'public',
      dateTime: _convertToDateTime(json['dateTime'] ?? ''),
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'docId': docId,
      'userText': userText,
      'userPost': userPost,
      'pathType': pathType,
      'dateTime': dateTime,
      'userState': userState
    };
  }


  Map<String, dynamic> postToMap() {
    bool isShared = postType == 'shared';
    return {
      'docId': docId,
      'userId': userId,
      'userText': userText,
      'userPost': userPost,
      'userState': userState,
      'dateTime': dateTime,
      'sharesNumber': sharesNumber,
      'postType': postType,
      'pathType': pathType,
      'isActive': isActive,
      if(isShared)...{
        'friendId': friendId,
        'friendText': friendText,
        'friendState': friendState,
        'originalDateTime': originalDateTime
      }
    };
  }

  static DateTime _convertToDateTime(dynamic timestamp) {
    if (timestamp == null) return DateTime.now();
    if (timestamp is Timestamp) return timestamp.toDate();
    if (timestamp is DateTime) return timestamp;
    return DateTime.now();
  }
}







