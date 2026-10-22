import 'package:flutter/cupertino.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:social_app/core/data/models/my_model.dart';
import 'package:social_app/core/services/data/session_service.dart';
import '../../domain/data_sources/remote/firestore/firestore_service.dart';
import 'package:social_app/core/services/domain/i_user_account_service.dart';


class UserAccountService implements IUserAccountService {
  final FirestoreService _dataSource;
  final SessionService _sessionService;

  UserAccountService({
    required FirestoreService dataSource,
    required SessionService sessionService
  })
      : _dataSource = dataSource,
        _sessionService = sessionService;

  @override
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
      debugPrint('Error in getAccount: $e');
      return {};
    }
  }

  @override
  Future<Map<String, dynamic>> getAccountMap({
    required DocumentSnapshot userDoc,
  }) async {
    try {
      final userAccount = userDoc.data() as Map<String, dynamic>? ?? {};
      return await getUserAccount(userAccount: userAccount);
    } catch (e) {
      debugPrint('Error in getAccount: $e');
      rethrow;
    }
  }

  @override
  Future<MyModel> getUserModelData({
    required String id,
  }) async {
    final userDoc = await _dataSource.getDoc(
        docId: id,
        collectionPath: 'accounts'
    );
    final data = await getAccountMap(userDoc: userDoc);
    return MyModel.fromJson(data);
  }

  @override
  Future<MyModel> getUserAccountData() async {
    final docData = await _dataSource.getDoc(
        collectionPath: 'accounts',
        docId: _sessionService.currentUid
    );
    final userAccount = await getAccountMap(userDoc: docData);
    return MyModel.fromJson(userAccount);
  }
}