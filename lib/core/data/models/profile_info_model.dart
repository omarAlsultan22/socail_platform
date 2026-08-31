import 'package:social_app/core/data/models/post_model.dart';
import 'package:social_app/core/data/models/user_model.dart';


class ProfileInfoModel extends UserModel{
  final String userState;
  final String userWork;
  final String userLive;
  final String userFrom;
  final String userRelational;
  late PostModel? profileImage;
  late PostModel? coverImage;

  ProfileInfoModel({
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

  factory ProfileInfoModel.fromJson(Map<String, dynamic> json) {
    return ProfileInfoModel(
      userState: json['userState'] ?? '',
      userWork: json['userWork'] ?? '',
      userLive: json['userLive'] ?? '',
      userFrom: json['userFrom'] ?? '',
      userRelational: json['userRelational'] ?? '',
    );
  }

  factory ProfileInfoModel.fromFirestore(Map<String, dynamic> json) {
    return ProfileInfoModel(
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
  Map<String, dynamic> toJson() {
    return {
      'userState': userState,
      'userWork': userWork,
      'userLive': userLive,
      'userFrom': userFrom,
      'userRelational': userRelational,
    };
  }
}

