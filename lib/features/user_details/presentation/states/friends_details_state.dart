import 'package:social_app/core/data/models/my_model.dart';
import 'package:social_app/features/public/data/models/user_details.dart';


class FriendsDetailsState {
  final Map<String, UserDetails> friendsDetails;

  FriendsDetailsState({required this.friendsDetails});

  factory FriendsDetailsState.initial() =>
      FriendsDetailsState(friendsDetails: {});

  FriendsDetailsState updateFriend(String key, MyModel friendModel) {
    return FriendsDetailsState(friendsDetails: {
      ...friendsDetails,
      key: UserDetails(
        myName: friendModel.myName,
        myImageUrl: friendModel.myImageUrl,
      ),
    });
  }
}