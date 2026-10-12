import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:social_app/core/data/models/base/json_model.dart';


class UserAccount implements JsonModel{
  final String userId;
  final bool? isOnline;
  final String lastName;
  final String fullName;
  final String firstName;
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
        isOnline: isOnline ?? this.isOnline,
        lastName: lastName ?? this.lastName,
        fullName: fullName ?? this.fullName,
        firstName: firstName ?? this.fullName,
        userImage: userImage ?? this.userImage,
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



