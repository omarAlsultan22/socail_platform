import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:social_app/core/data/models/user_model.dart';
import 'package:social_app/core/constants/user_details.dart';


class UserAccountService {

  Future<Map<String, dynamic>> getUserAccount({
    required Map<String, dynamic> userAccount,
  }) async {
    try {
      if (userAccount['userImage'] is DocumentReference) {
        final imageDocRef = userAccount['userImage'] as DocumentReference;
        final imageDoc = await imageDocRef.get();

        if (imageDoc.exists && imageDoc.data() != null) {
          final imageData = imageDoc.data() as Map<String, dynamic>;
          userAccount['userImage'] = imageData['userPost'] as String? ?? '';
        } else {
          userAccount['userImage'] = '';
        }
      }
      return userAccount;
    }
    catch (e) {
      print('Error in getAccount: $e');
      return {};
    }
  }


  Future<Map<String, dynamic>> getAccountMap({
    required DocumentSnapshot userDoc,
  }) async {
    try {
      final userAccount = userDoc.data() as Map<String, dynamic>? ?? {};
      return await getUserAccount(userAccount: userAccount);
    } catch (e) {
      print('Error in getAccount: $e');
      return {};
    }
  }

  Future<UserModel> getUserModelData({
    required String id,
  })async {
    UserModel userModel;
    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('accounts').doc(id).get();
      final data = await getAccountMap(userDoc: userDoc);
      UserModel accountData = UserModel.fromJson(data);
      userModel = accountData;
    } catch (e) {
      rethrow;
    }
    return userModel;
  }

  Future<UserModel>getUserAccountData()async {
    final firestore = FirebaseFirestore.instance;
    final docData = await firestore.collection('accounts').doc(UserDetails.uId).get();
    final userAccount = await getAccountMap(userDoc: docData);
    UserModel userModel = UserModel.fromJson(userAccount);
    return userModel;
  }
}