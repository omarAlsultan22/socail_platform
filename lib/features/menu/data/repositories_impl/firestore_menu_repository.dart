import 'package:firebase_auth/firebase_auth.dart';
import 'package:social_app/core/data/models/profile_info_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:social_app/models/account_model.dart';
import '../../../../core/constants/user_details.dart';
import 'package:social_app/features/menu/domain/repositories/menu_repository.dart';
import 'package:social_app/core/presentation/data/repositories_impl/firestore_base_repository.dart';


class FirestoreMenuRepository extends FirestoreBaseRepository implements MenuRepository{
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Future<UserAccount> getAccount(String uId) async {
    try {
      final docRef = _firestore.collection('accounts').doc(uId);
      final docSnapshot = await docRef.get();

      if (!docSnapshot.exists) {
        throw Exception('Account document does not exist');
      }

      final data = docSnapshot.data() as Map<String, dynamic>;
      return UserAccount.fromJson(data);
    }
    catch(e){
      rethrow;
    }
  }

  @override
  Future<void> updateAccount({
    required UserAccount userAccount,
  }) async {
    try {
      await _firestore
          .collection('accounts')
          .doc(UserDetails.uId)
          .update(userAccount.toJson());
    }
    catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> updateProfileInfo({
    required ProfileInfoModel infoModel
  }) async {
    try {
      await FirebaseFirestore.instance
          .collection('info')
          .doc(UserDetails.uId)
          .set(infoModel.toJson(), SetOptions(merge: true));
    } catch (e) {
      rethrow;
    }
  }
}
