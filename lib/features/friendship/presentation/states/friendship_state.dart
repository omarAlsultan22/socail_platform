import '../../../../core/data/models/user_model.dart';
import '../../data/models/friendship_success_state.dart';
import 'package:social_app/core/data/models/message_result.dart';
import '../../../../core/presentation/states/app_sub_states.dart';
import '../../../../core/errors/exceptions/base/app_exception.dart';
import '../../../../core/presentation/states/base/main_app_sub_state.dart';
import 'package:social_app/core/presentation/states/base/main_app_sup_state.dart';


class FriendshipState extends MainAppSupState {
  final MessageResult messageResult;
  final List<UserModel> friendsRequestsList;
  final List<UserModel> friendsSuggestsList;
  const FriendshipState({
    required this.friendsRequestsList,
    required this.friendsSuggestsList,
    required this.messageResult,
    required super.subState
  });

  factory FriendshipState.initial() {
    return FriendshipState(
      subState: InitialState(),
      friendsRequestsList: const [],
      friendsSuggestsList: const [],
      messageResult: MessageResult.initial(),
    );
  }

  bool get friendsRequestsListIsEmpty => friendsRequestsList.isEmpty;

  FriendshipState copyWith({
    MainAppSubState? subState,
    MessageResult? messageResult,
    List<UserModel>? friendsRequestsList,
    List<UserModel>? friendsSuggestsList,
  }) {
    return FriendshipState(
      subState: subState ?? this.subState,
      messageResult: messageResult ?? this.messageResult,
      friendsRequestsList: friendsRequestsList ?? this.friendsRequestsList,
      friendsSuggestsList: friendsSuggestsList ?? this.friendsSuggestsList,
    );
  }

  FriendshipState addFriendSuggest(int index) {
    if (friendsSuggestsList.isEmpty || index >= friendsSuggestsList.length) return this;

    final newSuggestsList = List<UserModel>.from(friendsSuggestsList)
      ..removeAt(index);

    return copyWith(
        friendsSuggestsList: newSuggestsList,
        messageResult: MessageResult.success(
            message: 'The request has been sent successfully')
    );
  }

  FriendshipState confirmFriend(int index) {
    if (friendsRequestsList.isEmpty) return this;

    final newRequestsList = List<UserModel>.from(friendsRequestsList)
      ..removeAt(index);

    return copyWith(
      friendsRequestsList: newRequestsList,
      messageResult: MessageResult.success(
          message: 'Your friend request has been approved'),
    );
  }

  FriendshipState declineFriendRequest(int index) {
    if (friendsRequestsList.isEmpty) return this;

    final newRequestsList = List<UserModel>.from(friendsRequestsList)
      ..removeAt(index);

    return copyWith(
      friendsRequestsList: newRequestsList,
      messageResult: MessageResult.success(message: 'Deleted Successfully')
    );
  }

  FriendshipState updateFriendsRequestsList(List<UserModel> newList) {
    return copyWith(
      friendsRequestsList: newList,
      subState: SuccessState(),
    );
  }

  FriendshipState updateFriendsSuggestsList(List<UserModel> newList) {
    return copyWith(
      friendsSuggestsList: newList,
      subState: SuccessState(),
    );
  }

  FriendshipState deleteFriendSuggest(int index) {
    if (friendsSuggestsList.isEmpty || index >= friendsSuggestsList.length) return this;

    final newSuggestsList = List<UserModel>.from(friendsSuggestsList)
      ..removeAt(index);

    return copyWith(
      friendsSuggestsList: newSuggestsList,
      messageResult: MessageResult.success(message: 'Deleted Successfully')
    );
  }

  String? getUid(UserModel userModel) => userModel.userId;
  UserModel getFriendRequestByIndex(int index) => friendsRequestsList[index];
  UserModel getFriendSuggestByIndex(int index) => friendsSuggestsList[index];

  @override
  FriendshipSuccessState get dataModels => FriendshipSuccessState(
      friendsRequestsList: friendsRequestsList,
      friendsSuggestsList: friendsSuggestsList
  );

  @override
  R when<R>({
    required R Function() onInitial,
    required R Function() onLoading,
    required R Function(FriendshipSuccessState) onLoaded,
    required R Function(AppException) onError
  }) {
    return subState.when(
        onInitial: onInitial,
        onLoading: onLoading,
        onLoaded: () => onLoaded.call(dataModels),
        onError: (failure) => onError.call(failure)
    );
  }
}