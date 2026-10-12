import 'package:social_app/core/data/models/post_model.dart';
import 'package:social_app/core/data/models/base/json_model.dart';


class ProfileInfo extends JsonModel{
  final String userState;
  final String userWork;
  final String userLive;
  final String userFrom;
  final String userRelational;
  final PostModel? coverImage;

  ProfileInfo({
    this.coverImage,
    required this.userState,
    required this.userWork,
    required this.userLive,
    required this.userFrom,
    required this.userRelational,
  });

  factory ProfileInfo.initial(){
    return ProfileInfo(
      userState: '',
      userWork: '',
      userLive: '',
      userFrom: '',
      userRelational: '',
    );
  }

  factory ProfileInfo.fromJson(Map<String, dynamic> json) {
    return ProfileInfo(
      userState: json['userState'] ?? '',
      userWork: json['userWork'] ?? '',
      userLive: json['userLive'] ?? '',
      userFrom: json['userFrom'] ?? '',
      userRelational: json['userRelational'] ?? '',
    );
  }

  factory ProfileInfo.fromFirestore(Map<String, dynamic> json) {
    return ProfileInfo(
        coverImage: json['userCover'] ?? '',
        userState: json['userState'] ?? '',
        userWork: json['userWork'] ?? '',
        userLive: json['userLive'] ?? '',
        userFrom: json['userFrom'] ?? '',
        userRelational: json['userRelational'] ?? '',
    );
  }

  String? get userPost => coverImage!.userPost;

  ProfileInfo copyWith({
    String? userLive,
    String? userFrom,
    String? userWork,
    String? userState,
    PostModel? coverImage,
    String? userRelational,
  }) {
    return ProfileInfo(
        userWork: userWork ?? this.userWork,
        userLive: userLive ?? this.userLive,
        userFrom: userFrom ?? this.userFrom,
        userState: userState ?? this.userState,
        coverImage: coverImage ?? this.coverImage,
        userRelational: userRelational ?? this.userRelational
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

