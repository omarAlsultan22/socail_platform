import 'package:social_app/core/data/models/user_model.dart';
import 'package:social_app/core/data/models/my_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:video_player/video_player.dart';
import 'comment_model.dart';
import 'dart:io';


class PostModel extends UserModel{
  File? file;
  bool hasMeLiked;
  String myDocId;
  String userPost;
  String postType;
  String? pathType;
  int? likesNumber;
  int? commentsNumber;
  bool isProfilePost;
  late int? sharesNumber;
  final bool postIsShared;
  final UserModel? userModel;
  final List<MyModel>? likesList;
  final List<CommentModel>? commentsList;
  VideoPlayerController? videoController;

  PostModel({
    super.myId,
    super.myState,
    super.originalDateTime,
    super.userState,
    super.userText,
    super.userId,
    super.userName,
    super.userImage,
    super.userDocId,
    super.meIsOnline,
    this.postType = '',
    this.pathType,
    this.file,
    this.hasMeLiked = false,
    this.sharesNumber,
    this.likesNumber,
    this.commentsNumber,
    this.myDocId = '',
    super.myDateTime,
    this.userModel,
    this.likesList,
    this.commentsList,
    this.userPost = '',
    this.videoController,
    this.postIsShared = false,
    this.isProfilePost = false,
  });

  factory PostModel.fromFirestoreToPost(Map<String, dynamic> json) {
    final isShared = json['postType'] == 'shared';
    return PostModel(
        myId: json['userId'] ?? '',
        myDocId: json['docId'] ?? '',
        userText: json['userText'] ?? '',
        userPost: json['userPost'] ?? '',
        pathType: json['pathType'] ?? '',
        myState: json['userState'] ?? 'public',
        hasMeLiked: json['hasMeLiked'] ?? false,
        myDateTime: _convertToDateTime(json['dateTime'] ?? ''),
        sharesNumber: json['sharesNumber'] ?? 0,
        likesNumber: json['likesNumber'] ?? 0,
        commentsNumber: json['commentsNumber'] ?? 0,
        meIsOnline: json['isOnline'] ?? false,
        likesList: json['likesList'] ?? [],
        commentsList: json['commentsList'] ?? [],
        userModel: isShared ?
        UserModel(
            userId: json['friendId'] ?? '',
            userName: json['friendName'] ?? '',
            userImage: json['friendImage'] ?? '',
            userDocId: json['friendDocId'] ?? '',
            originalDateTime: _convertToDateTime(json['originalDateTime'] ?? ''),
            userText: json['friendText'] ?? '',
            userState: json['friendState'] ?? ''
        ) : UserModel()
    );
  }


  factory PostModel.fromFirestoreToStatus(Map<String, dynamic> json) {
    return PostModel(
      myId: json['userId'] ?? '',
      myDocId: json['docId'] ?? '',
      pathType: json['pathType'] ?? '',
      userPost: json['userPost'] ?? '',
      userText: json['userText'] ?? '',
      meIsOnline: json['isOnline'] ?? false,
      myState: json['userState'] ?? 'public',
      myDateTime: _convertToDateTime(json['dateTime'] ?? ''),
    );
  }

  PostModel copyWith({
    File? file,
    String? myDocId,
    bool? meIsOnline,
    bool? isActive,
    String? myId,
    String? postType,
    String? userPost,
    String? pathType,
    String? userText,
    String? myState,
    DateTime? dateTime,
    UserModel? userModel,
    DateTime? originalDateTime,
    List<MyModel>? likesList,
    List<CommentModel>? commentsList,
    VideoPlayerController? videoController
}) {
    return PostModel(
        file: file ?? this.file,
        myId: myId ?? this.myId,
        myState: myState ?? this.myState,
        myDocId: myDocId ?? this.myDocId,
        userPost: userPost ?? this.userPost,
        postType: postType ?? this.postType,
        pathType: pathType ?? this.pathType,
        userText: userText ?? this.userText,
        userModel: userModel ?? this.userModel,
        likesList: likesList ?? this.likesList,
        meIsOnline: meIsOnline ?? this.meIsOnline,
        commentsList: commentsList ?? this.commentsList,
        videoController: videoController ?? this.videoController
    );
  }

  bool get myIdIsEmpty  => myId.isEmpty;
  bool get myDocIdIsEmpty  => myDocId.isEmpty;
  bool get userPostIsEmpty => userPost.isEmpty;
  bool get userTextIsEmpty => userText!.isEmpty;
  double get aspectRatio => videoController!.value.aspectRatio;
  bool get videoIsInitialized => videoController!.value.isInitialized;

  Future<void>? get playVideo async => await videoController?.play();
  Future<void>? get pauseVideo async => await videoController?.pause();
  Future<void>? get seekToVideo async => await videoController?.seekTo(Duration.zero);

  @override
  Map<String, dynamic> toJson() {
    return {
      'userId': myId,
      'docId': myDocId,
      'userText': userText,
      'userPost': userPost,
      'pathType': pathType,
      'dateTime': myDateTime,
      'userState': myState
    };
  }

  Map<String, dynamic> postToMap() {
    return {
      'userId': myId,
      'docId': myDocId,
      'userText': userText,
      'userPost': userPost,
      'postType': postType,
      'pathType': pathType,
      'userState': myState,
      'dateTime': myDateTime,
      'hasMeLiked': hasMeLiked,
      'postIsShared': postIsShared,
      if(postIsShared)...{
        'friendId': userModel!.userId,
        'friendText': userModel!.userText,
        'friendState': userModel!.userState,
        'friendDocId': userModel!.userDocId,
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







