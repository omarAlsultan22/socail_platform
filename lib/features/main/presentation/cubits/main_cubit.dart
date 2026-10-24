import 'dart:async';
import '../states/main_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/use_cases/main_use_case.dart';
import 'package:social_app/core/constants/app_strings.dart';
import 'package:social_app/core/services/data/session_service.dart';
import '../../../../core/services/domain/i_notification_service.dart';
import '../../../../core/services/domain/i_user_account_service.dart';
import '../../../../core/presentation/mixins/error_handler_mixin.dart';


class MainCubit extends Cubit<MainState> with ErrorHandlerMixin<MainState> {
  final MainUseCases _useCases;
  final SessionService _sessionService;
  final IUserAccountService _userAccountService;
  final INotificationService _notificationService;

  StreamSubscription? _notificationsSub;
  StreamSubscription? _friendRequestsSub;
  final List<StreamSubscription> _messagesSubs = [];

  MainCubit({
    required MainUseCases useCase,
    required SessionService sessionService,
    required IUserAccountService userAccountService,
    required INotificationService notificationService
  })
      : _useCases = useCase,
        _sessionService = sessionService,
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
    if (state.friendshipCount > 0) {
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

  Future<void> checkOnAnyFriends() async {
    emit(state.successState());

    try {
      final suggests = await _useCases.executeCheckOnAnyFriends(uId: _sessionService.currentUid);
      emit(state.updateSuggestsList(suggests));
      emit(state.successState());
    } catch (e, stackTrace) {
      handleError(e, stackTrace,
          onError: (failure) =>
              state.copyWith()
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
      ]);

      emit(state.setMessageListenerActive(true));
      emit(state.successState());
    } catch (e, stackTrace) {
      emit(state.setMessageListenerActive(true));
      handleError(e, stackTrace,
          onError: (failure) =>
              state.copyWith()
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
              id: doc[AppStrings.friendId]);
          if (state.isMessageActive) {
            _notificationService.sendInteractionNotification({
              ...doc.data() as Map<String, dynamic>,
              'friendName': userModel.myName,
            });
          }
        }

        emit(state.updateNotifications(
          counter: data.count,
          docIds: newDocIds,
        ));
        emit(state.successState());
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
        emit(state.successState());
      },
    );
  }

  void changeIsMessage() {
    emit(state.setMessageListenerActive(false));
    emit(state.successState());
  }

  @override
  Future<void> close() async {
    await _cancelAllSubscriptions();
    changeIsMessage();
    return super.close();
  }
}