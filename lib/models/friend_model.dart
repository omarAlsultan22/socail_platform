import 'package:social_app/models/user_model.dart';


class UserData extends UserModel {
  late String? friendId;
  late String? friendName;
  late String? friendImage;
  late String? friendText;
  late String? friendState;
  late bool? friendIsOnline;
  late DateTime? originalDateTime;

  UserData({
    super.userId,
    super.userName,
    super.userImage,
    super.dateTime,
    super.isOnline,
    this.friendId,
    this.friendName,
    this.friendImage,
    this.friendText,
    this.friendState,
    this.friendIsOnline,
    this.originalDateTime
  });
}

