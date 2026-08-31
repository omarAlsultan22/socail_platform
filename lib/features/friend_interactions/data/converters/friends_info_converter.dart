import '../../../../core/data/models/user_model.dart';
import '../../../../core/constants/user_details.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../shared/componentes/public_components.dart';


class FriendsInfoConverter {
  final List<UserModel> data;

  FriendsInfoConverter({required this.data});

  static Future<FriendsInfoConverter> fromQuerySnapshotSuggests(
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
    return FriendsInfoConverter(data: data);
  }
}