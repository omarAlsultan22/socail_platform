import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
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


  Map<String, dynamic> toMap(){
    return {
      'userId': userId,
      'dateTime': dateTime
    };
  }
}

class UserModelList {
  UserModel userModel;

  UserModelList({required this.userModel});

  factory UserModelList.fromDocumentSnapshot(DocumentSnapshot snapshot){
    final json = snapshot.data() as Map<String, dynamic>;

    UserModel userModel = UserModel.fromJson(json);
    return UserModelList(userModel: userModel);
  }
}



