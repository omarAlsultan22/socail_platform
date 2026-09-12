import 'package:social_app/core/data/models/base/json_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class UserAccount implements JsonModel{
  final String userId;
  final String firstName;
  final String lastName;
  final String fullName;
  bool? isOnline;
  final DocumentReference? userImage;

  UserAccount({
    this.isOnline,
    this.userImage,
    required this.userId,
    required this.firstName,
    required this.lastName,
    required this.fullName,
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

  UserAccount copyWith({
    String? userId,
    String? firstName,
    String? lastName,
    String? fullName,
    bool? isOnline,
    DocumentReference? userImage,
}) {
    return UserAccount(
        userId: userId ?? this.userId,
        firstName: firstName ?? this.fullName,
        lastName: lastName ?? this.lastName,
        fullName: fullName ?? this.fullName,
        userImage: userImage ?? this.userImage,
        isOnline: isOnline ?? this.isOnline
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



