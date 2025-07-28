import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:social_app/models/user_model.dart';
import '../shared/componentes/constants.dart';
import '../shared/componentes/public_components.dart';

class UserData extends UserModel {
  late String? friendId;
  late String? friendName;
  late String? friendImage;
  late String? friendText;
  late String? friendState;
  late bool? friendIsOnline;
  late DateTime? originalDateTime;

  UserData({
    super.userId,
    super.userName,
    super.userImage,
    super.dateTime,
    super.isOnline,
    this.friendId,
    this.friendName,
    this.friendImage,
    this.friendText,
    this.friendState,
    this.friendIsOnline,
    this.originalDateTime
  });
}

class FriendsListInfo {
  final List<UserModel> data;

  FriendsListInfo({required this.data});

  static Future<FriendsListInfo> fromQuerySnapshotSuggests(
      QuerySnapshot requests,
      QuerySnapshot friends,
      QuerySnapshot suggests
      ) async {
    final List<UserModel> data = [];
    final Set<String> requestIds = requests.docs.map((doc) => doc.id).toSet();
    final Set<String> friendsIds = friends.docs.map((doc) => doc.id).toSet();

    for (final suggestDoc in suggests.docs) {
      try {
        if (!requestIds.contains(suggestDoc.id) &&
            !friendsIds.contains(suggestDoc.id) &&
            suggestDoc.id != UserDetails.uId
        ) {
          final userData = await getUserModelData(id: suggestDoc.id);
          if (userData != null) {
            data.add(userData);
          }
        }
      } catch (e) {
        print('Error processing user ${suggestDoc.id}: $e');
      }
    }

    return FriendsListInfo(data: data);
  }
}