import '../../domain/repositories/user_info_repository.dart';
import 'package:social_app/core/data/models/profile_info.dart';
import '../../../../core/domain/data_sources/remote/firestore/firestore_service.dart';


class UserInfoRepositoryImpl implements UserInfoRepository {
  final FirestoreService _dataSource;

  UserInfoRepositoryImpl({
    required FirestoreService dataSource
  })
      : _dataSource = dataSource;

  @override
  Future<Map<String, dynamic>> getInfo({
    required String uId
  }) async {
    final getUserInfo = await _dataSource.getDoc(
        docId: uId, collectionPath: 'info');
    if (getUserInfo.exists) {
      final userInfo = getUserInfo.data() as Map<String, dynamic>;

      return userInfo;
    }
    return {};
  }

  @override
  Future<void> updateProfileInfo({
    required String docId,
    required ProfileInfo infoModel
  }) async {
    await _dataSource.setSupDoc(
      docId: docId,
      isMerge: true,
      collectionPath: 'info',
      data: infoModel.toJson(),
    );
  }
}
