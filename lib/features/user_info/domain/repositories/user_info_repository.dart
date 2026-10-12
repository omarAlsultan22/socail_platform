import '../../../../core/data/models/profile_info.dart';
import '../../../../core/domain/repositories/base_repository.dart';


abstract class UserInfoRepository implements BaseRepository {
  Future<void> updateProfileInfo({
    required String docId,
    required ProfileInfo infoModel
  });
}