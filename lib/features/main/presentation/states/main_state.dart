import 'package:social_app/core/data/models/user_model.dart';


class MainState {
  final int currentScreen;
  final int friendshipCount;
  final int notificationsCount;
  final int messagesCount;
  final Set<String> friendRequestsDocIds;
  final Set<String> notificationsDocIds;
  final Set<String> messagesIds;
  final List<UserModel> suggestsList;
  final bool isMessageActive;

  const MainState({
    this.messagesCount = 0,
    this.currentScreen = 0,
    this.notificationsCount = 0,
    this.friendshipCount = 0,
    this.suggestsList = const [],
    this.messagesIds = const {},
    this.notificationsDocIds = const {},
    this.friendRequestsDocIds = const {},
    this.isMessageActive = false,
  });

  factory MainState.initial() {
    return MainState(
      messagesCount: 0,
      currentScreen: 0,
      notificationsCount: 0,
      friendshipCount: 0,
      suggestsList: const [],
      messagesIds: const {},
      notificationsDocIds: const {},
      friendRequestsDocIds: const {},
      isMessageActive: false,
    );
  }

  MainState copyWith({
    int? messagesCount,
    int? currentScreen,
    bool? isMessageActive,
    int? notificationsCount,
    int? friendshipCount,
    Set<String>? messagesIds,
    List<UserModel>? suggestsList,
    Set<String>? notificationsDocIds,
    Set<String>? friendRequestsDocIds,
  }) {
    return MainState(
      suggestsList: suggestsList ?? this.suggestsList,
      messagesIds: messagesIds ?? this.messagesIds,
      messagesCount: messagesCount ?? this.messagesCount,
      currentScreen: currentScreen ?? this.currentScreen,
      notificationsDocIds: notificationsDocIds ?? this.notificationsDocIds,
      notificationsCount: notificationsCount ?? this.notificationsCount,
      friendRequestsDocIds: friendRequestsDocIds ?? this.friendRequestsDocIds,
      friendshipCount: friendshipCount ??
          this.friendshipCount,
      isMessageActive: isMessageActive ??
          this.isMessageActive,
    );
  }

  MainState successState() {
    return copyWith();
  }

  MainState changeScreen(int index) {
    return copyWith(
      currentScreen: index,
    );
  }

  MainState updateFriendRequests({
    required int counter,
    required Set<String> docIds,
  }) {
    return copyWith(
      friendshipCount: counter,
      friendRequestsDocIds: docIds,
    );
  }

  MainState updateNotifications({
    required int counter,
    required Set<String> docIds,
  }) {
    return copyWith(
      notificationsCount: counter,
      notificationsDocIds: docIds,
    );
  }

  MainState updateMessages({
    required int counter,
    required Set<String> docIds,
  }) {
    return copyWith(
      messagesCount: counter,
      messagesIds: docIds,
    );
  }

  MainState updateSuggestsList(List<UserModel> newList) {
    return copyWith(
      suggestsList: newList,
    );
  }

  MainState decrementFriendRequest() {
    if (friendshipCount > 0) {
      return copyWith(
        friendshipCount: friendshipCount - 1,
      );
    }
    return this;
  }

  MainState decrementNotification() {
    if (notificationsCount > 0) {
      return copyWith(
        notificationsCount: notificationsCount - 1,
      );
    }
    return this;
  }

  MainState decrementMessage() {
    if (messagesCount > 0) {
      return copyWith(
        messagesCount: messagesCount - 1,
      );
    }
    return this;
  }

  MainState setMessageListenerActive(bool active) {
    return copyWith(
      isMessageActive: active,
    );
  }
}