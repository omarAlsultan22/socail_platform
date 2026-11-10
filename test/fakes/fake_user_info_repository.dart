import 'package:social_app/core/data/models/profile_info.dart';
import 'package:social_app/features/user_info/domain/repositories/user_info_repository.dart';


class FakeUserInfoRepository implements UserInfoRepository {
  // ===== getInfo =====
  Map<String, dynamic> getInfoResult = {};
  Object? getInfoError;
  int getInfoCallCount = 0;
  String? lastGetInfoUid;

  @override
  Future<Map<String, dynamic>> getInfo({required String uId}) async {
    getInfoCallCount++;
    lastGetInfoUid = uId;
    if (getInfoError != null) throw getInfoError!;
    return getInfoResult;
  }

  // ===== updateProfileInfo =====
  int updateProfileInfoCallCount = 0;
  String? lastUpdateDocId;
  ProfileInfo? lastUpdateInfoModel;
  Object? updateProfileInfoError;

  @override
  Future<void> updateProfileInfo({
    required String docId,
    required ProfileInfo infoModel,
  }) async {
    updateProfileInfoCallCount++;
    lastUpdateDocId = docId;
    lastUpdateInfoModel = infoModel;
    if (updateProfileInfoError != null) throw updateProfileInfoError!;
  }
}