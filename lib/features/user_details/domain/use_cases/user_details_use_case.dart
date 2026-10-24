import 'dart:async';
import '../../../../core/data/models/my_model.dart';
import '../repositories/user_details_repository.dart';
import 'package:social_app/core/constants/app_strings.dart';
import '../../../../core/services/data/session_service.dart';
import '../../../../core/services/domain/i_user_account_service.dart';


class UserDetailsUseCase {
  final SessionService _sessionService;
  final UserDetailsRepository _repository;
  final IUserAccountService _userAccountService;

  UserDetailsUseCase({
    required SessionService sessionService,
    required UserDetailsRepository repository,
    required IUserAccountService userAccountService
  })
      : _repository = repository,
        _sessionService = sessionService,
        _userAccountService = userAccountService;

  Stream<MyModel>? executeGetUserDetails({String? uId}) {
      return _repository.getMyDetailsStream(
          collectionPath: AppStrings.accounts, docId: uId ?? _sessionService.currentUid
      ).asyncMap((userDoc) async {
        final data = await _userAccountService.getAccountMap(userDoc: userDoc);
        return MyModel.fromJson(data);
      });
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