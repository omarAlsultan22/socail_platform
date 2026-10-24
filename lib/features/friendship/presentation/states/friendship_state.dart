import '../../../../core/data/models/my_model.dart';
import '../../data/models/friendship_success_state.dart';
import 'package:social_app/core/data/models/message_result.dart';
import '../../../../core/presentation/states/app_sub_states.dart';
import '../../../../core/errors/exceptions/base/app_exception.dart';
import '../../../../core/presentation/states/base/main_app_sub_state.dart';
import 'package:social_app/core/presentation/states/base/main_app_sup_state.dart';


class FriendshipState extends MainAppSupState {
  final MessageResult messageResult;
  final List<MyModel> friendsRequestsList;
  final List<MyModel> friendsSuggestsList;
  static const _deletedSuccessfully = 'Deleted Successfully';

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

  FriendshipState copyWith({
    MainAppSubState? subState,
    MessageResult? messageResult,
    List<MyModel>? friendsRequestsList,
    List<MyModel>? friendsSuggestsList,
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

    final newSuggestsList = List<MyModel>.from(friendsSuggestsList)
      ..removeAt(index);

    return copyWith(
        friendsSuggestsList: newSuggestsList,
        messageResult: MessageResult.success(
            message: 'The request has been sent successfully')
    );
  }

  FriendshipState confirmFriend(int index) {
    if (friendsRequestsList.isEmpty) return this;

    final newRequestsList = List<MyModel>.from(friendsRequestsList)
      ..removeAt(index);

    return copyWith(
      friendsRequestsList: newRequestsList,
      messageResult: MessageResult.success(
          message: 'Your friend request has been approved'),
    );
  }

  FriendshipState declineFriendRequest(int index) {
    if (friendsRequestsList.isEmpty) return this;

    final newRequestsList = List<MyModel>.from(friendsRequestsList)
      ..removeAt(index);

    return copyWith(
        friendsRequestsList: newRequestsList,
        messageResult: MessageResult.success(message: _deletedSuccessfully)
    );
  }

  FriendshipState updateFriendsRequestsList(List<MyModel> newList) {
    return copyWith(
      friendsRequestsList: newList,
      subState: SuccessState(),
    );
  }

  FriendshipState updateFriendsSuggestsList(List<MyModel> newList) {
    return copyWith(
      friendsSuggestsList: newList,
      subState: SuccessState(),
    );
  }

  FriendshipState deleteFriendSuggest(int index) {
    if (friendsSuggestsList.isEmpty || index >= friendsSuggestsList.length)
      return this;

    final newSuggestsList = List<MyModel>.from(friendsSuggestsList)
      ..removeAt(index);

    return copyWith(
        friendsSuggestsList: newSuggestsList,
        messageResult: MessageResult.success(message: _deletedSuccessfully)
    );
  }

  String? getUid(MyModel userModel) => userModel.myId;

  MyModel getFriendRequestByIndex(int index) => friendsRequestsList[index];

  MyModel getFriendSuggestByIndex(int index) => friendsSuggestsList[index];

  // ✅ State functions

  FriendshipState setLoadingMessage() {
    return copyWith(messageResult: MessageResult.loading());
  }

  FriendshipState setErrorMessage(AppException failure) {
    return copyWith(messageResult: MessageResult.error(failure: failure));
  }

  // ✅ Getters

  bool get allListsIsEmpty =>
      friendsRequestsList.isEmpty && friendsSuggestsList.isEmpty;

  @override
  FriendshipSuccessState get dataModels =>
      FriendshipSuccessState(
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