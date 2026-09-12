import 'package:social_app/core/data/models/base/json_model.dart';


class UserModel implements JsonModel {
  String? userId;
  final String? firstName;
  final String? lastName;
  final String? fullName;
  late String? userImage;
  late DateTime? dateTime;
  final bool isFriend;
  bool? isOnline;

  UserModel({
    this.isOnline,
    this.userId,
    this.firstName,
    this.lastName,
    this.fullName,
    this.userImage,
    this.dateTime,
    this.isFriend = false,
  });

  factory UserModel.fromJson(Map<String, dynamic> json){
    return UserModel(
        userId: json['userId'] ?? '',
        userImage: json['userImage'] ?? '',
        firstName: json['firstName'] ?? 'UnKnown',
        lastName: json['lastName'] ?? 'UnKnown',
        fullName: json['fullName'] ?? 'UnKnown',
        isOnline: json['isOnline'] ?? false
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'userImage': userImage,
      'firstName': firstName,
      'lastName': lastName,
      'fullName': fullName,
      'dateTime': dateTime
    };
  }
}



