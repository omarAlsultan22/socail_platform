import 'package:social_app/core/data/models/my_model.dart';


class UserModel extends MyModel {
  late String? userId;
  late String? userName;
  late String? userText;
  late String? userImage;
  late String? userState;
  late String? userDocId;
  late bool? userIsOnline;
  late DateTime? originalDateTime;

  UserModel({
    super.myId,
    super.myState,
    super.meIsOnline,
    this.userId,
    this.userName,
    this.userText,
    super.myDateTime,
    this.userImage,
    this.userState,
    this.userDocId,
    this.userIsOnline,
    this.originalDateTime
  });
}

