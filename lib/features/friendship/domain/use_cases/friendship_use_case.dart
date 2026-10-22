import '../repositories/friendship_repository.dart';
import '../../data/converters/friends_info_converter.dart';
import 'package:social_app/core/data/models/my_model.dart';
import 'package:social_app/core/services/data/session_service.dart';
import 'package:social_app/core/errors/exceptions/validation_exception.dart';


class FriendshipUseCase {
  final SessionService _sessionService;
  final FriendshipRepository _repository;

  FriendshipUseCase({
    required SessionService sessionService,
    required FriendshipRepository repository
  })
      : _repository = repository,
        _sessionService = sessionService;

  static final _validationException = ValidationException(
      error: 'User ID is empty'
  );

  Future<String> executeAddFriendRequest({String? uId}) async {
    if (uId != null || uId!.isEmpty) {
      throw _validationException;
    }

    MyModel friendInfo = MyModel(
        myDateTime: DateTime.now(),
        myId: _sessionService.currentUid
    );

    await _repository.addFriendRequestToFirestore(
      userId: uId,
      friendInfo: friendInfo,
    );
    return uId;
  }

  Future<String> executeConfirmNewFriend({String? uId}) async {
    if (uId != null || uId!.isEmpty) {
      throw _validationException;
    }

    await _repository.confirmFriendInFirestore(
      currentUserId: _sessionService.currentUid,
      friendId: uId,
    );
    return uId;
  }

  Stream<List<MyModel>> executeGetConversationsStream({
    required Future<MyModel> Function(String id) getUserModelData,
  }) {
    return _repository.getConversationsStream(
      userId: _sessionService.currentUid,
      getUserModelData: getUserModelData,
    );
  }

  Future<String> executeDeclineFriendRequest({String? uId}) async {
    if (uId != null || uId!.isEmpty) {
      throw _validationException;
    }

    await _repository.declineFriendRequestInFirestore(
      currentUserId: _sessionService.currentUid,
      friendId: uId,
    );
    return uId;
  }

  Future<List<MyModel>> executeGetFriendsSuggests() async {
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
}