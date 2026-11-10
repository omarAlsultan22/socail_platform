import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:social_app/core/data/models/my_model.dart';
import 'package:social_app/core/services/domain/i_user_account_service.dart';


class FakeUserAccountService implements IUserAccountService {
  // ===== getAccountMap =====
  Map<String, dynamic> getAccountMapResult = {};
  Object? getAccountMapError;
  int getAccountMapCallCount = 0;

  @override
  Future<Map<String, dynamic>> getAccountMap({
    required DocumentSnapshot userDoc,
  }) async {
    getAccountMapCallCount++;
    if (getAccountMapError != null) throw getAccountMapError!;
    return getAccountMapResult;
  }

  // ===== getUserModelData =====
  MyModel getUserModelDataResult = MyModel(
    myId: 'default-id',
    myDateTime: DateTime(2024),
  );
  Object? getUserModelDataError;
  int getUserModelDataCallCount = 0;
  String? lastGetUserModelDataId;

  @override
  Future<MyModel> getUserModelData({required String id}) async {
    getUserModelDataCallCount++;
    lastGetUserModelDataId = id;
    if (getUserModelDataError != null) throw getUserModelDataError!;
    return getUserModelDataResult;
  }

  // ===== getUserAccountData =====
  MyModel getUserAccountDataResult = MyModel(
    myId: 'default-id',
    myDateTime: DateTime(2024),
  );
  Object? getUserAccountDataError;
  int getUserAccountDataCallCount = 0; // ← جديد

  @override
  Future<MyModel> getUserAccountData() async {
    getUserAccountDataCallCount++;
    if (getUserAccountDataError != null) throw getUserAccountDataError!;
    return getUserAccountDataResult;
  }

  // ===== getUserAccount =====
  Map<String, dynamic> getUserAccountResult = {};
  Object? getUserAccountError;
  int getUserAccountCallCount = 0;

  @override
  Future<Map<String, dynamic>> getUserAccount({
    required Map<String, dynamic> userAccount,
  }) async {
    getUserAccountCallCount++;
    if (getUserAccountError != null) throw getUserAccountError!;
    return getUserAccountResult;
  }

  // باقي الدوال — noSuchMethod
  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError(
        'FakeUserAccountService.${invocation.memberName} not stubbed',
      );
}