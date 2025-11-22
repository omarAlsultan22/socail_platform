import '../models/user_model.dart';
import '../shared/constants/user_details.dart';
import '../shared/componentes/public_components.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


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