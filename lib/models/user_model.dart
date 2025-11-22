import 'package:social_app/models/map_model.dart';


class UserModel implements MapModel{
  String? userId;
  String? userName;
  late String? userImage;
  late DateTime? dateTime;
  final bool isFriend;
  bool? isOnline;


  UserModel({
    this.isOnline,
    this.userId,
    this.userName,
    this.userImage,
    this.dateTime,
    this.isFriend = false,
  });

  factory UserModel.fromJson(Map<String, dynamic> json){
    return UserModel(
      userId: json['userId'] ?? '',
      userName: json['fullName'] ?? '',
      userImage: json['userImage'] ?? '',
      isOnline: json['isOnline'] ?? false
    );
  }

  @override
  Map<String, dynamic> toMap(){
    return {
      'userId': userId,
      'dateTime': dateTime
    };
  }
}



