import '../repositories/user_info_repository.dart';
import '../../../../core/data/models/profile_info.dart';
import 'package:social_app/core/services/data/session_service.dart';


class UserInfoUseCase {
  final UserInfoRepository _repository;
  final SessionService _sessionService;

  UserInfoUseCase({
    required UserInfoRepository repository,
    required SessionService sessionService
  })
      : _repository = repository,
        _sessionService = sessionService;

  Future<ProfileInfo> executeGetInfo() async {
    final userInfo = await _repository.getInfo(uId: _sessionService.currentUid);
    return ProfileInfo.fromJson(userInfo);
  }

  Future<void> executeUpdateInfo({
    required final String userState,
    required final String userWork,
    required final String userLive,
    required final String userFrom,
    required final String userRelational,
  }) async {
    ProfileInfo infoModel = ProfileInfo(
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
  }
}
