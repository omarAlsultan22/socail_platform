import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:social_app/core/data/models/my_model.dart';
import 'package:social_app/core/services/session_service.dart';
import 'package:social_app/core/data/data_sources/remote/firestore/firestore_base_service.dart';


class UserAccountService {
  final SessionService _sessionService;
  final FirestoreBaseService _repository;

  UserAccountService({
    required SessionService sessionService,
    required FirestoreBaseService repository
  })
      : _repository = repository,
        _sessionService = sessionService;

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

  Future<MyModel> getUserModelData({
    required String id,
  }) async {
    MyModel userModel;
    try {
      final userDoc = await _repository.getDoc(
          docId: id,
          collectionPath: 'accounts'
      );
      final data = await getAccountMap(userDoc: userDoc);
      MyModel accountData = MyModel.fromJson(data);
      userModel = accountData;
    } catch (e) {
      rethrow;
    }
    return userModel;
  }

  Future<MyModel> getUserAccountData() async {
    final docData = await _repository.getDoc(
        collectionPath: 'accounts',
        docId: _sessionService.currentUid
    );
    final userAccount = await getAccountMap(userDoc: docData);
    MyModel userModel = MyModel.fromJson(userAccount);
    return userModel;
  }
}