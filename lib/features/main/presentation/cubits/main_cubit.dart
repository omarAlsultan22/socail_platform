import 'dart:async';
import '../states/main_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/useCases/main_use_case.dart';
import '../../../../core/services/notification_service.dart';
import 'package:social_app/core/services/user_account_service.dart';
import '../../../../core/presentation/mixins/error_handler_mixin.dart';
import 'package:social_app/core/presentation/states/app_sub_states.dart';


class MainCubit extends Cubit<MainState> with ErrorHandlerMixin<MainState> {
  final MainUseCases _useCases;
  final UserAccountService _userAccountService;
  final NotificationService _notificationService;

  StreamSubscription? _notificationsSub;
  StreamSubscription? _friendRequestsSub;
  List<StreamSubscription> _messagesSubs = [];

  MainCubit({
    required MainUseCases useCase,
    required UserAccountService userAccountService,
    required NotificationService notificationService
  })
      : _useCases = useCase,
        _userAccountService = userAccountService,
        _notificationService = notificationService,
        super(MainState.initial());

  static MainCubit get(context) => BlocProvider.of(context);

  void changeIndexScreen(int index) {
    if (state.currentScreen != index) {
      emit(state.changeScreen(index));
    }
  }

  void deleteRequest() {
    if (state.friendRequestsCount > 0) {
      emit(state.decrementFriendRequest());
    }
  }

  void deleteNotification() {
    if (state.notificationsCount > 0) {
      emit(state.decrementNotification());
    }
  }

  void deleteMessage() {
    if (state.messagesCount > 0) {
      emit(state.decrementMessage());
    }
  }

  Future<void> checkOnAnyFriends({required String uId}) async {
    emit(state.copyWith(subState: LoadingState()));

    try {
      final suggests = await _useCases.executeCheckOnAnyFriends(uId: uId);
      emit(state.updateSuggestsList(suggests));
      emit(state.copyWith(subState: SuccessState()));
    } catch (e, stackTrace) {
      handleError(e, stackTrace,
          onError: (failure) =>
              state.copyWith(
                  subState: ErrorState(failure: failure)
              )
      );
    }
  }

  Future<void> startListeningToCounters() async {
    await _cancelAllSubscriptions();
    emit(state.setMessageListenerActive(false));

    try {
      await Future.wait([
        _setupNotificationsListener(),
        _setupFriendRequestsListener(),
        _setupMessagesListener(),
      ]);

      emit(state.setMessageListenerActive(true));
      emit(state.copyWith(subState: SuccessState()));
    } catch (e, stackTrace) {
      emit(state.setMessageListenerActive(true));
      handleError(e, stackTrace,
          onError: (failure) =>
              state.copyWith(
                  subState: ErrorState(failure: failure)
              )
      );
    }
  }

  Future<void> _cancelAllSubscriptions() async {
    await _notificationsSub?.cancel();
    await _friendRequestsSub?.cancel();

    for (final sub in _messagesSubs) {
      await sub.cancel();
    }

    _notificationsSub = null;
    _friendRequestsSub = null;
    _messagesSubs.clear();
  }

  Future<void> _setupNotificationsListener() async {
    final initialData = await _useCases.executeGetInitialNotificationsCount();
    emit(state.updateNotifications(
      counter: initialData.count,
      docIds: initialData.docIds,
    ));

    _notificationsSub = _useCases.executeGetNotificationsStream().listen(
          (data) async {
        final newDocIds = Set<String>.from(data.docIds);

        for (var doc in data.docs) {
          final userModel = await _userAccountService.getUserModelData(
              id: doc['friendId']);
          if (state.isMessageActive) {
            _notificationService.sendInteractionNotification({
              ...doc.data() as Map<String, dynamic>,
              'friendName': userModel.fullName,
            });
          }
        }

        emit(state.updateNotifications(
          counter: data.count,
          docIds: newDocIds,
        ));
        emit(state.copyWith(subState: SuccessState()));
      },
    );
  }

  Future<void> _setupFriendRequestsListener() async {
    final initialData = await _useCases.executeGetInitialFriendRequestsCount();
    emit(state.updateFriendRequests(
      counter: initialData.count,
      docIds: initialData.docIds,
    ));

    _friendRequestsSub = _useCases.executeGetFriendRequestsStream().listen(
          (data) {
        final newDocIds = Set<String>.from(data.docIds);

        if (state.isMessageActive) {
          _notificationService.sendFriendRequestNotification();
        }

        emit(state.updateFriendRequests(
          counter: data.count,
          docIds: newDocIds,
        ));
        emit(state.copyWith(subState: SuccessState()));
      },
    );
  }

  Future<void> _setupMessagesListener() async {
    final initialData = await _useCases.executeGetInitialMessagesCount();
    _messagesSubs = initialData.subscriptions;

    emit(state.updateMessages(
      counter: initialData.count,
      docIds: initialData.docIds,
    ));

    final messagesQuery = await _useCases.getMessages();

    for (final doc in messagesQuery.docs) {
      final subscription = _useCases.executeGetMessagesStreamForDoc(
        doc.id,
        state.messagesCount,
        state.messagesIds,
      ).listen((data) {
        if (state.isMessageActive) {
          _notificationService.sendMessageNotification();
        }

        emit(state.updateMessages(
          counter: data.count,
          docIds: data.docIds,
        ));
        emit(state.copyWith(subState: SuccessState()));
      });

      _messagesSubs.add(subscription);
    }
  }

  void changeIsMessage() {
    emit(state.setMessageListenerActive(false));
    emit(state.copyWith(subState: SuccessState()));
  }

  @override
  Future<void> close() async {
    await _cancelAllSubscriptions();
    changeIsMessage();
    return super.close();
  }
}