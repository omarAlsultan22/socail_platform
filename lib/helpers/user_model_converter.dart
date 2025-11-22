import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';


class UserModelList {
  UserModel userModel;

  UserModelList({required this.userModel});

  factory UserModelList.fromDocumentSnapshot(DocumentSnapshot snapshot){
    final json = snapshot.data() as Map<String, dynamic>;

    UserModel userModel = UserModel.fromJson(json);
    return UserModelList(userModel: userModel);
  }
}