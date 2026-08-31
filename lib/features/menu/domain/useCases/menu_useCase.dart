import '../../../../core/data/models/profile_info_model.dart';
import '../repositories/menu_repository.dart';
import 'package:social_app/core/data/models/account_model.dart';
import '../../../../core/constants/user_details.dart';


class MenuUseCases {
  final MenuRepository _repository;

  MenuUseCases({required MenuRepository repository})
      : _repository = repository;

  Future<ProfileInfoModel> executeGetInfo(String uId) async {
    try {
      final userInfo = await _repository.getInfo(uid: uId);
      return ProfileInfoModel.fromJson(userInfo);
    }
    catch (e) {
      rethrow;
    }
  }

  Future<UserAccount> executeGetAccount(String uId) async {
    try {
      return await _repository.getAccount(uId);
    }
    catch (e) {
      rethrow;
    }
  }

  Future<void> executeUpdateAccount({
    required String firstName,
    required String lastName,
    required String phone,
  }) async {
    final userAccount = UserAccount(
      userId: UserDetails.uId,
      firstName: firstName,
      lastName: lastName,
      fullName: '$firstName $lastName',
    );
    try {
      await _repository.updateAccount(userAccount: userAccount);
    }
    catch (e) {
      rethrow;
    }
  }

  Future<void> updateProfileInfo({
    required final String userState,
    required final String userWork,
    required final String userLive,
    required final String userFrom,
    required final String userRelational,
  }) async {
    try {
      ProfileInfoModel infoModel = ProfileInfoModel(
        userState: userState,
        userWork: userWork,
        userLive: userLive,
        userFrom: userFrom,
        userRelational: userRelational,
      );
      _repository.updateProfileInfo(infoModel: infoModel);
    } catch (e) {
      rethrow;
    }
  }
}
