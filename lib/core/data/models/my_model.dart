import 'package:social_app/core/data/models/base/json_model.dart';


class MyModel implements JsonModel {
  final String myId;
  late String myName;
  final bool isFriend;
  final String myState;
  final bool meIsOnline;
  late String myImageUrl;
  late DateTime? myDateTime;

  MyModel({
    this.myId = '',
    this.myName = '',
    this.myDateTime,
    this.myState = '',
    this.myImageUrl = '',
    this.meIsOnline = false,
    this.isFriend = false
  });

  bool get userIdIsEmpty => myId.isEmpty;
  bool get myImageUrlIsEmpty => myImageUrl.isEmpty;

  factory MyModel.fromJson(Map<String, dynamic> json){
    return MyModel(
        myId: json['userId'] ?? '',
        myName: json['fullName'] ?? '',
        myImageUrl: json['userImage'] ?? '',
        meIsOnline: json['isOnline'] ?? false
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'userId': myId,
      'dateTime': myDateTime
    };
  }
}




