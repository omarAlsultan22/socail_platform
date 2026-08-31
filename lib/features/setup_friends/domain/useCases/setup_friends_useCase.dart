import 'package:social_app/core/data/models/user_model.dart';
import '../repositories/setup_friends_repository.dart';
import '../../../../core/constants/user_details.dart';


class SetupFriendsUseCase {
  final SetupFriendsRepository _repository;

  SetupFriendsUseCase({required SetupFriendsRepository repository})
      : _repository = repository;

  Future<List<UserModel>> executeGetSuggestsUsers() async {
    return await _repository.getSuggestsUsers();
  }

  Future<void> executeConfirmNewFriend({
    required String friendId,
  }) async {
    await _repository.confirmNewFriend(
      currentUserId: UserDetails.uId,
      friendId: friendId,
    );
  }
}