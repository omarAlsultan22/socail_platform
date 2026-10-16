import 'dart:async';
import '../../../../core/data/models/my_model.dart';
import '../../../../core/services/session_service.dart';
import '../../../../core/services/user_account_service.dart';
import '../../data/repositories_impl/user_details_repository_impl.dart';


class UserDetailsUseCase {
  final SessionService _sessionService;
  final UserDetailsRepositoryImpl _repository;
  final UserAccountService _userAccountService;

  UserDetailsUseCase({
    required SessionService sessionService,
    required UserDetailsRepositoryImpl repository,
    required UserAccountService userAccountService
  })
      : _repository = repository,
        _sessionService = sessionService,
        _userAccountService = userAccountService;

  Stream<MyModel>? executeGetUserDetails({String? uId}) {
    try {
      return _repository.getMyDetailsStream(
          collectionPath: 'accounts', docId: uId ?? _sessionService.currentUid
      ).asyncMap((userDoc) async {
        final data = await _userAccountService.getAccountMap(userDoc: userDoc);
        return MyModel.fromJson(data);
      });
    }
    catch (e) {
      rethrow;
    }
  }

  Stream<Map<String, Stream<MyModel>>> executeGetNotificationsStream() {
    return _repository.getFriendsList(_sessionService.currentUid).asyncMap((
        friendsSnapshot) {
      final friendsUIds = friendsSnapshot.docs.map((doc) => doc.id).toList();

      final currentUid = _sessionService.currentUid;
      if (!friendsUIds.contains(currentUid)) {
        friendsUIds.add(currentUid);
      }

      final Map<String, Stream<MyModel>> result = {};

      for (final uId in friendsUIds) {
        final stream = executeGetUserDetails(uId: uId);
        if (stream != null) {
          result[uId] = stream;
        }
      }

      return result;
    });
  }
}