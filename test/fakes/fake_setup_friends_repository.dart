import 'package:social_app/core/data/models/my_model.dart';
import 'package:social_app/features/setup_friends/domain/repositories/setup_friends_repository.dart';


class FakeSetupFriendsRepository implements SetupFriendsRepository {
  // ===== getSuggestsUsers =====
  List<MyModel> getSuggestsUsersResult = [];
  Object? getSuggestsUsersError;
  int getSuggestsUsersCallCount = 0;

  @override
  Future<List<MyModel>> getSuggestsUsers() async {
    getSuggestsUsersCallCount++;
    if (getSuggestsUsersError != null) throw getSuggestsUsersError!;
    return getSuggestsUsersResult;
  }

  // ===== confirmNewFriend =====
  int confirmNewFriendCallCount = 0;
  String? lastFriendId;
  Object? confirmNewFriendError;

  @override
  Future<void> confirmNewFriend({required String friendId}) async {
    confirmNewFriendCallCount++;
    lastFriendId = friendId;
    if (confirmNewFriendError != null) throw confirmNewFriendError!;
  }
}