import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:social_app/core/data/models/my_model.dart';


abstract class IUserAccountService {
  Future<Map<String, dynamic>> getUserAccount({
    required Map<String, dynamic> userAccount,
  });

  Future<Map<String, dynamic>> getAccountMap({
    required DocumentSnapshot userDoc,
  });

  Future<MyModel> getUserModelData({
    required String id,
  });

  Future<MyModel> getUserAccountData();
}