import '../../../../core/data/models/user_model.dart';
import 'package:social_app/core/data/models/message_result.dart';
import '../../../../core/presentation/states/app_sub_states.dart';
import '../../../../core/errors/exceptions/base/app_exception.dart';
import '../../../../core/presentation/states/base/main_app_sub_state.dart';
import 'package:social_app/core/presentation/states/base/main_app_sup_state.dart';
import 'package:social_app/features/friends_interactions/data/models/friends_interactions_success_state.dart';


class FriendsInteractionsState extends MainAppSupState {
  final MessageResult messageResult;
  final List<UserModel> friendsRequestsList;
  final List<UserModel> friendsSuggestsList;
  const FriendsInteractionsState({
    required this.friendsRequestsList,
    required this.friendsSuggestsList,
    required this.messageResult,
    required super.subState
  });

  factory FriendsInteractionsState.initial() {
    return FriendsInteractionsState(
      subState: InitialState(),
      friendsRequestsList: const [],
      friendsSuggestsList: const [],
      messageResult: MessageResult.initial(),
    );
  }

  FriendsInteractionsState copyWith({
    MainAppSubState? subState,
    MessageResult? messageResult,
    List<UserModel>? friendsRequestsList,
    List<UserModel>? friendsSuggestsList,
  }) {
    return FriendsInteractionsState(
      subState: subState ?? this.subState,
      messageResult: messageResult ?? this.messageResult,
      friendsRequestsList: friendsRequestsList ?? this.friendsRequestsList,
      friendsSuggestsList: friendsSuggestsList ?? this.friendsSuggestsList,
    );
  }

  FriendsInteractionsState addFriendRequest(int index) {
    if (friendsSuggestsList.isEmpty || index >= friendsSuggestsList.length) return this;

    final newSuggestsList = List<UserModel>.from(friendsSuggestsList)
      ..removeAt(index);

    return copyWith(
      friendsSuggestsList: newSuggestsList,
      subState: SuccessState(),
    );
  }

  FriendsInteractionsState confirmFriend(String userId) {
    if (friendsRequestsList.isEmpty) return this;

    final newRequestsList = List<UserModel>.from(friendsRequestsList)
      ..removeWhere((item) => item.userId == userId);

    return copyWith(
      friendsRequestsList: newRequestsList,
      subState: SuccessState(),
    );
  }

  FriendsInteractionsState declineFriendRequest(String userId) {
    if (friendsRequestsList.isEmpty) return this;

    final newRequestsList = List<UserModel>.from(friendsRequestsList)
      ..removeWhere((item) => item.userId == userId);

    return copyWith(
      friendsRequestsList: newRequestsList,
    );
  }

  FriendsInteractionsState updateFriendsRequestsList(List<UserModel> newList) {
    return copyWith(
      friendsRequestsList: newList,
      subState: SuccessState(),
    );
  }

  FriendsInteractionsState updateFriendsSuggestsList(List<UserModel> newList) {
    return copyWith(
      friendsSuggestsList: newList,
      subState: SuccessState(),
    );
  }

  FriendsInteractionsState deleteFriendSuggest(int index) {
    if (friendsSuggestsList.isEmpty || index >= friendsSuggestsList.length) return this;

    final newSuggestsList = List<UserModel>.from(friendsSuggestsList)
      ..removeAt(index);

    return copyWith(
      friendsSuggestsList: newSuggestsList,
    );
  }

  @override
  FriendsInteractionsSuccessState get dataModels => FriendsInteractionsSuccessState(
      friendsRequestsList: friendsRequestsList,
      friendsSuggestsList: friendsSuggestsList
  );

  @override
  R when<R>({
    required R Function() onInitial,
    required R Function() onLoading,
    required R Function(FriendsInteractionsSuccessState) onLoaded,
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