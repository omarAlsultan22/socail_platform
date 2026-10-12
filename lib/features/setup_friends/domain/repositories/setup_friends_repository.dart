import 'package:social_app/core/data/models/my_model.dart';


abstract class SetupFriendsRepository {

  Future<List<MyModel>> getSuggestsUsers();

  Future<void> confirmNewFriend({
    required String friendId,
  });
}