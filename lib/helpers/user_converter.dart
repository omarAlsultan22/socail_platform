import '../core/data/models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class UserModelConverter {
  UserModel userModel;

  UserModelConverter({required this.userModel});

  factory UserModelConverter.fromDocumentSnapshot(DocumentSnapshot snapshot){
    final json = snapshot.data() as Map<String, dynamic>;

    UserModel userModel = UserModel.fromJson(json);
    return UserModelConverter(userModel: userModel);
  }
}