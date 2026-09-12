import 'package:social_app/core/presentation/domain/repositories/base_repository.dart';
import 'package:social_app/core/data/models/account_model.dart';
import '../../../../core/data/models/profile_info_model.dart';


abstract class UserInfoRepository implements BaseRepository {
  Future<void> updateProfileInfo({
    required String docId,
    required ProfileInfoModel infoModel
  });
}