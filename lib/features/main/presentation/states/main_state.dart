import 'package:social_app/core/data/models/user_model.dart';
import '../../../../core/presentation/states/app_sub_states.dart';
import '../../../../core/errors/exceptions/base/app_exception.dart';
import 'package:social_app/core/presentation/states/app_sup_states.dart';
import '../../../../core/presentation/states/base/main_loaded_state.dart';
import '../../../../core/presentation/states/base/main_app_sub_state.dart';


class MainState extends DoubleModelAppState<int, UserModel> {
  final int currentScreenIndex;
  final int friendRequestsCounter;
  final int notificationsCounter;
  final int messagesCounter;
  final Set<String> friendRequestsDocIds;
  final Set<String> notificationsDocIds;
  final Set<String> messagesDocIds;
  final List<UserModel> suggestsList;
  final bool isMessageListenerActive;

  MainState({
    super.firstModel,
    super.secondModel,
    required super.subState,
    this.currentScreenIndex = 0,
    this.friendRequestsCounter = 0,
    this.notificationsCounter = 0,
    this.messagesCounter = 0,
    this.friendRequestsDocIds = const {},
    this.notificationsDocIds = const {},
    this.messagesDocIds = const {},
    this.suggestsList = const [],
    this.isMessageListenerActive = false,
  });

  factory MainState.initial() {
    return MainState(
      firstModel: 0,
      secondModel: null,
      subState: InitialState(),
      currentScreenIndex: 0,
      friendRequestsCounter: 0,
      notificationsCounter: 0,
      messagesCounter: 0,
      friendRequestsDocIds: const {},
      notificationsDocIds: const {},
      messagesDocIds: const {},
      suggestsList: const [],
      isMessageListenerActive: false,
    );
  }

  @override
  MainState copyWith({
    int? firstModel,
    Never? thirdModel,
    int? messagesCounter,
    UserModel? secondModel,
    int? currentScreenIndex,
    int? notificationsCounter,
    MainAppSubState? subState,
    int? friendRequestsCounter,
    Set<String>? messagesDocIds,
    List<UserModel>? suggestsList,
    bool? isMessageListenerActive,
    Set<String>? notificationsDocIds,
    Set<String>? friendRequestsDocIds,
  }) {
    return MainState(
      subState: subState ?? this.subState,
      firstModel: firstModel ?? this.firstModel,
      secondModel: secondModel ?? this.secondModel,
      suggestsList: suggestsList ?? this.suggestsList,
      messagesDocIds: messagesDocIds ?? this.messagesDocIds,
      messagesCounter: messagesCounter ?? this.messagesCounter,
      currentScreenIndex: currentScreenIndex ?? this.currentScreenIndex,
      notificationsDocIds: notificationsDocIds ?? this.notificationsDocIds,
      notificationsCounter: notificationsCounter ?? this.notificationsCounter,
      friendRequestsDocIds: friendRequestsDocIds ?? this.friendRequestsDocIds,
      friendRequestsCounter: friendRequestsCounter ??
          this.friendRequestsCounter,
      isMessageListenerActive: isMessageListenerActive ??
          this.isMessageListenerActive,
    );
  }

  MainState changeScreen(int index) {
    return copyWith(
      currentScreenIndex: index,
      subState: SuccessState(),
    );
  }

  MainState updateFriendRequests({
    required int counter,
    required Set<String> docIds,
  }) {
    return copyWith(
      friendRequestsCounter: counter,
      friendRequestsDocIds: docIds,
      subState: SuccessState(),
    );
  }

  MainState updateNotifications({
    required int counter,
    required Set<String> docIds,
  }) {
    return copyWith(
      notificationsCounter: counter,
      notificationsDocIds: docIds,
    );
  }

  MainState updateMessages({
    required int counter,
    required Set<String> docIds,
  }) {
    return copyWith(
      messagesCounter: counter,
      messagesDocIds: docIds,
    );
  }

  MainState updateSuggestsList(List<UserModel> newList) {
    return copyWith(
      suggestsList: newList,
    );
  }

  MainState decrementFriendRequest() {
    if (friendRequestsCounter > 0) {
      return copyWith(
        friendRequestsCounter: friendRequestsCounter - 1,
      );
    }
    return this;
  }

  MainState decrementNotification() {
    if (notificationsCounter > 0) {
      return copyWith(
        notificationsCounter: notificationsCounter - 1,
      );
    }
    return this;
  }

  MainState decrementMessage() {
    if (messagesCounter > 0) {
      return copyWith(
        messagesCounter: messagesCounter - 1,
      );
    }
    return this;
  }

  MainState setMessageListenerActive(bool active) {
    return copyWith(
      isMessageListenerActive: active,
    );
  }

  int get messagesCount => messagesCounter;

  int get currentScreen => currentScreenIndex;

  Set<String> get messagesIds => messagesDocIds;

  int get notificationsCount => notificationsCounter;

  bool get isMessageActive => isMessageListenerActive;

  int get friendRequestsCount => friendRequestsCounter;

  @override
  R when<R>({
    required R Function() onInitial,
    required R Function() onLoading,
    required R Function(LoadedState) onLoaded,
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