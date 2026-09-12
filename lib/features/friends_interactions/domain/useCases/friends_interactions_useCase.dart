import '../../data/converters/friends_info_converter.dart';
import 'package:social_app/core/data/models/user_model.dart';
import '../repositories/friends_interactions_repository.dart';
import 'package:social_app/core/services/session_service.dart';
import 'package:social_app/core/errors/exceptions/validation_exception.dart';


class FriendsInteractionsUseCase {
  final SessionService _sessionService;
  final FriendsInteractionsRepository _repository;

  FriendsInteractionsUseCase({
    required SessionService sessionService,
    required FriendsInteractionsRepository repository
  })
      : _repository = repository,
        _sessionService = sessionService;

  static final _validationException = ValidationException(
      error: 'User ID is empty');

  Future<String> executeAddFriendRequest() async {
    final userId = _sessionService.currentUid;
    if (userId.isEmpty) {
      throw _validationException;
    }

    UserModel friendInfo = UserModel(
        dateTime: DateTime.now(),
        userId: _sessionService.currentUid
    );

    await _repository.addFriendRequestToFirestore(
      userId: userId,
      friendInfo: friendInfo,
    );

    return userId;
  }

  Future<String> executeConfirmNewFriend() async {
    final userId = _sessionService.currentUid;
    if (userId.isEmpty) {
      throw _validationException;
    }

    await _repository.confirmFriendInFirestore(
      currentUserId: _sessionService.currentUid,
      friendId: userId,
    );

    return userId;
  }

  Stream<List<UserModel>> executeGetConversationsStream({
    required Future<UserModel> Function(String id) getUserModelData,
  }) {
    return _repository.getConversationsStream(
      userId: _sessionService.currentUid,
      getUserModelData: getUserModelData,
    );
  }

  Future<String> executeDeclineFriendRequest() async {
    final userId = _sessionService.currentUid;
    if (userId.isEmpty) {
      throw _validationException;
    }

    await _repository.declineFriendRequestInFirestore(
      currentUserId: _sessionService.currentUid,
      friendId: userId,
    );

    return userId;
  }

  Future<List<UserModel>> executeGetFriendsSuggests() async {
    final data = await _repository.getFriendsSuggestData(
      currentUserId: _sessionService.currentUid,
    );

    FriendsInfoConverter friendsInfo = await FriendsInfoConverter
        .fromQuerySnapshotSuggests(
        data.friends,
        data.requests,
        data.allUsers
    );

    return friendsInfo.data;
  }

  Future<void> executeUpdateFriendRequestsCount({
    required String docId,
  }) async {
    await _repository.deleteRequestFromFirestore(
      currentUserId: _sessionService.currentUid,
      docId: docId,
    );
  }
}