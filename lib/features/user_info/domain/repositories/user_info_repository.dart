import '../../../../core/data/models/profile_info.dart';


abstract class UserInfoRepository {
  Future<Map<String, dynamic>> getInfo({
    required String uId
  });

  Future<void> updateProfileInfo({
    required String docId,
    required ProfileInfo infoModel
  });
}