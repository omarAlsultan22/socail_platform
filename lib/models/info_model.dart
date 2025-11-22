import 'package:social_app/models/post_model.dart';
import 'package:social_app/models/user_model.dart';


class InfoModel extends UserModel{
  final String userState;
  final String userWork;
  final String userLive;
  final String userFrom;
  final String userRelational;
  late PostModel? profileImage;
  late PostModel? coverImage;

  InfoModel({
    super.userName,
    super.userId,
    super.isOnline,
    this.coverImage,
    this.profileImage,
    required this.userState,
    required this.userWork,
    required this.userLive,
    required this.userFrom,
    required this.userRelational,
  });

  factory InfoModel.fromJson(Map<String, dynamic> json) {
    return InfoModel(
      userState: json['userState'] ?? '',
      userWork: json['userWork'] ?? '',
      userLive: json['userLive'] ?? '',
      userFrom: json['userFrom'] ?? '',
      userRelational: json['userRelational'] ?? '',
    );
  }

  factory InfoModel.fromFirestore(Map<String, dynamic> json) {
    return InfoModel(
        userId: json['userId'] ?? '',
        userName: json['userName'] ?? '',
        profileImage: json['userImage'] ?? '',
        coverImage: json['userCover'] ?? '',
        userState: json['userState'] ?? '',
        userWork: json['userWork'] ?? '',
        userLive: json['userLive'] ?? '',
        userFrom: json['userFrom'] ?? '',
        userRelational: json['userRelational'] ?? '',
        isOnline: json['isOnline'] ?? false
    );
  }


  @override
  Map<String, dynamic> toMap() {
    return {
      'userState': userState,
      'userWork': userWork,
      'userLive': userLive,
      'userFrom': userFrom,
      'userRelational': userRelational,
    };
  }
}

