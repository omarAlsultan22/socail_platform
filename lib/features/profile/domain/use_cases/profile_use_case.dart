import '../../../../core/services/domain/i_user_account_service.dart';
import '../repositories/profile_repository.dart';
import '../../data/converters/Info_data_converter.dart';
import 'package:social_app/core/data/models/my_model.dart';
import 'package:social_app/core/data/models/post_model.dart';
import 'package:social_app/core/data/models/user_info_model.dart';


class ProfileUseCase {
  final ProfileRepository _repository;
  final IUserAccountService _userAccountService;
  final AccountDataConverter _accountDataConverter;

  ProfileUseCase({
    required ProfileRepository repository,
    required IUserAccountService userAccountService,
    required AccountDataConverter accountDataConverter
  })
      : _repository = repository,
        _userAccountService = userAccountService,
        _accountDataConverter = accountDataConverter;


  Future<UserInfoModel?> executeGetProfileInfo(String uid) async {
    final data = await _repository.getProfileInfo(uid);
    if (data.account != null) {
      return _accountDataConverter.fromDocumentSnapshot(data.info, data.account);
    }
    return null;
  }

  Future<void> executeUploadImage({
    required PostModel postModel,
    required String collection,
    required String imageType,
  }) async {
    final userModel = await _userAccountService.getUserAccountData();
    final newPostModel = postModel.copyWith(
      myId: userModel.myId,
    );

    await _repository.uploadImage(
      imageType: imageType,
      postModel: newPostModel,
      collectionPath: collection
    );
  }

  Future<void> executeSendFriendRequest(String userId, MyModel friendInfo) async {
    await _repository.sendFriendRequest(userId, friendInfo);
  }

  Future<void> executeDeleteFriendRequest(String userId) async {
    await _repository.deleteFriendRequest(userId);
  }

  Future<void> executeDeleteFriendship(String userId) async {
    await _repository.deleteFriendship(userId);
  }

  Future<void> executeAddFriend(String userId, MyModel friendInfo) async {
    await _repository.addFriend(userId, friendInfo);
  }

  Future<bool> executeCheckIsRequest(String userId) async {
    return await _repository.checkRequestExists(userId);
  }

  Future<bool> executeCheckIsFriend(String userId) async {
    return await _repository.checkFriendExists(userId);
  }
}