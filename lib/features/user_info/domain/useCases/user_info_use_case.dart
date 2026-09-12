import '../repositories/user_info_repository.dart';
import '../../../../core/data/models/profile_info_model.dart';
import 'package:social_app/core/services/session_service.dart';


class UserInfoUseCase {
  final UserInfoRepository _repository;
  final SessionService _sessionService;

  UserInfoUseCase({
    required UserInfoRepository repository,
    required SessionService sessionService
  })
      : _repository = repository,
        _sessionService = sessionService;

  Future<ProfileInfoModel> executeGetInfo() async {
    try {
      final userInfo = await _repository.getInfo(uid: _sessionService.currentUid);
      return ProfileInfoModel.fromJson(userInfo);
    }
    catch (e) {
      rethrow;
    }
  }

  Future<void> executeUpdateInfo({
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
      _repository.updateProfileInfo(
          infoModel: infoModel,
          docId: _sessionService.currentUid
      );
    } catch (e) {
      rethrow;
    }
  }
}
