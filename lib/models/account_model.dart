import 'package:cloud_firestore/cloud_firestore.dart';

class UserAccount {
  final String userId;
  final String firstName;
  final String lastName;
  final String fullName;
  final String? userPhone;
  final DocumentReference? userImage;
  bool? isOnline;

  UserAccount({
    required this.userId,
    required this.firstName,
    required this.lastName,
    required this.fullName,
    this.userPhone,
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
        userPhone: json['userPhone'] ?? '',
        isOnline: json['isOnline'] ?? false
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'firstName': firstName,
      'lastName': lastName,
      'fullName': fullName,
      'userPhone': userPhone,
    };
  }
}

class AccountModel {
  Map<String, dynamic> modelMap;

  AccountModel({required this.modelMap});

  factory AccountModel.fromDocumentSnapshot(DocumentSnapshot snapshot){
    Map <String, dynamic> modelMap = {};
    if (snapshot.data() != null) {
      modelMap = snapshot.data() as Map<String, dynamic>;
    }
    return AccountModel(modelMap: modelMap);
  }
}


