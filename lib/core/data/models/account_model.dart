import 'package:social_app/core/data/models/base/json_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class UserAccount implements JsonModel{
  final String userId;
  final String firstName;
  final String lastName;
  final String fullName;
  final DocumentReference? userImage;
  bool? isOnline;

  UserAccount({
    required this.userId,
    required this.firstName,
    required this.lastName,
    required this.fullName,
    this.userImage,
    this.isOnline
  });

  factory UserAccount.fromJson(Map<String, dynamic> json) {
    return UserAccount(
        userId: json['userId'] ?? '',
        firstName: json['firstName'] ?? '',
        lastName: json['lastName'] ?? '',
        fullName: json['fullName'] ?? '',
        userImage: json['userImage'] ?? '',
        isOnline: json['isOnline'] ?? false
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'firstName': firstName,
      'lastName': lastName,
      'fullName': fullName,
    };
  }
}



