import 'package:social_app/core/data/models/user_model.dart';


abstract class SetupFriendsRepository {

  Future<List<UserModel>> getSuggestsUsers();

  Future<void> confirmNewFriend({
    required String currentUserId,
    required String friendId,
  });
}