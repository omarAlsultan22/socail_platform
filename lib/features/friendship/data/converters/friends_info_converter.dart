import '../../../../core/di/service _locator.dart';
import '../../../../core/data/models/my_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:social_app/core/services/data/session_service.dart';
import '../../../../core/services/domain/i_user_account_service.dart';


class FriendsInfoConverter {
  final List<MyModel> data;

  FriendsInfoConverter({required this.data});

  static final _sessionService = sl<SessionService>();
  static final _userAccountService = sl<IUserAccountService>();

  static Future<FriendsInfoConverter> fromQuerySnapshotSuggests(
      QuerySnapshot requests,
      QuerySnapshot friends,
      QuerySnapshot suggests
      ) async {
    final List<MyModel> data = [];
    final Set<String> requestIds = requests.docs.map((doc) => doc.id).toSet();
    final Set<String> friendsIds = friends.docs.map((doc) => doc.id).toSet();

    for (final suggestDoc in suggests.docs) {
      try {
        if (!requestIds.contains(suggestDoc.id) &&
            !friendsIds.contains(suggestDoc.id) &&
            suggestDoc.id != _sessionService.currentUid
        ) {
          final userData = await _userAccountService.getUserModelData(id: suggestDoc.id);
            data.add(userData);
        }
      } catch (e) {
        print('Error processing user ${suggestDoc.id}: $e');
      }
    }
    return FriendsInfoConverter(data: data);
  }
}