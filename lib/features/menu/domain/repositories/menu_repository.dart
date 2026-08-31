import 'package:social_app/core/presentation/domain/repositories/base_repository.dart';
import 'package:social_app/models/account_model.dart';
import '../../../../core/data/models/profile_info_model.dart';


abstract class MenuRepository implements BaseRepository {

  Future<UserAccount> getAccount(String uId);

  Future<void> updateAccount({
    required UserAccount userAccount,
  });

  Future<void> updateProfileInfo({
    required ProfileInfoModel infoModel
  });
}