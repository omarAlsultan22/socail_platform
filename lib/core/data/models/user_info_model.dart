import 'package:social_app/core/data/models/my_model.dart';
import 'package:social_app/core/data/models/post_model.dart';


class UserInfoModel extends MyModel {
  final PostModel? coverImage;
  final PostModel? profileImage;

  UserInfoModel({
    super.myId,
    super.myState,
    this.coverImage,
    super.meIsOnline,
    this.profileImage,
  });

  String get coverImageDocId => profileImage!.myDocId;

  String get profileImageDocId => coverImage!.myDocId;

  String get coverImageUrl => coverImage!.userPost;

  bool get coverImageIsEmpty => coverImageUrl.isEmpty;

  String get profileImageUrl => profileImage!.userPost;

  bool get profileImageIsEmpty => profileImageUrl.isEmpty;

  factory UserInfoModel.fromJson(Map<String, dynamic> json) {
    return UserInfoModel(
        myId: json['userId'] ?? '',
        myState: json['userState'] ?? '',
        coverImage: json['coverImage'] ?? '',
        profileImage: json['userImage'] ?? '',
        meIsOnline: json['isOnline'] ?? false
    );
  }

  UserInfoModel copyWith({
    String? myId,
    String? myState,
    bool? meIsOnline,
    PostModel? coverImage,
    PostModel? profileImage,
  }) {
    return UserInfoModel(
        myId: myId ?? this.myId,
        myState: myState ?? this.myState,
        coverImage: coverImage ?? this.coverImage,
        meIsOnline: meIsOnline ?? this.meIsOnline,
        profileImage: profileImage ?? this.profileImage
    );
  }
}



