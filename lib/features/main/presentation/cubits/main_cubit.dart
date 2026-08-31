import 'dart:async';
import '../states/main_state.dart';
import 'package:flutter/material.dart';
import '../../../../core/data/models/user_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/useCases/main_use_case.dart';
import '../../../public/presentation/screens/public_screen.dart';
import '../../../profile/presentation/screens/my_profile_screen.dart';
import 'package:social_app/core/presentation/states/app_sub_states.dart';
import '../../../notifications/presentation/screens/notifications_screen.dart';
import 'package:social_app/features/friend_interactions/presentation/screens/friend_interactions_screen.dart';


class MainLayoutCubit extends Cubit<MainState> with ErrorHandlerMixin<MainState> {
  final MainUseCases _useCases;

  StreamSubscription? _notificationsSub;
  StreamSubscription? _friendRequestsSub;
  List<StreamSubscription> _messagesSubs = [];

  final List<Widget> mainScreens = [
    HomeScreen(),
    NotificationsScreen(),
    FriendInteractionsScreen(),
    ProfileScreen(),
  ];

  MainLayoutCubit({required MainUseCases useCases})
      : _useCases = useCases,
        super(MainState.initial());

  static MainLayoutCubit get(context) => BlocProvider.of(context);

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
    emit(state.setLoading());

    try {
      final suggests = await _useCases.executeCheckOnAnyFriends(uId: uId);
      emit(state.updateSuggestsList(suggests));
      emit(state.setSuccess());
    } catch (error) {
      emit(state.setError(error.toString()));
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
      emit(state.setSuccess());
    } catch (error) {
      emit(state.setMessageListenerActive(true));
      emit(state.setError(error.toString()));
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
    // جلب البيانات الأولية
    final initialData = await _useCases.executeGetInitialNotificationsCount();
    emit(state.updateNotifications(
      counter: initialData.count,
      docIds: initialData.docIds,
    ));

    // الاستماع للتغييرات
    _notificationsSub = _useCases.executeGetNotificationsStream().listen(
          (data) async {
        final newDocIds = Set<String>.from(data.docIds);

        for (var doc in data.docs) {
          final userModel = await getUserModelData(id: doc['friendId']);
          if (state.isMessageActive) {
            NotificationService().sendInteractionNotification({
              ...doc.data() as Map<String, dynamic>,
              'friendName': userModel.userName,
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
    // جلب البيانات الأولية
    final initialData = await _useCases.executeGetInitialFriendRequestsCount();
    emit(state.updateFriendRequests(
      counter: initialData.count,
      docIds: initialData.docIds,
    ));

    // الاستماع للتغييرات
    _friendRequestsSub = _useCases.executeGetFriendRequestsStream().listen(
          (data) {
        final newDocIds = Set<String>.from(data.docIds);

        if (state.isMessageActive) {
          NotificationService().sendFriendRequestNotification();
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
    // جلب البيانات الأولية
    final initialData = await _useCases.executeGetInitialMessagesCount();
    _messagesSubs = initialData.subscriptions;

    emit(state.updateMessages(
      counter: initialData.count,
      docIds: initialData.docIds,
    ));

    // جلب أسماء المستندات لإعداد الـ streams
    final messagesQuery = await FirebaseFirestore.instance.collection(
        'messages').get();

    for (final doc in messagesQuery.docs) {
      final subscription = _useCases.executeGetMessagesStreamForDoc(
        doc.id,
        state.messagesCount,
        state.messagesIds,
      ).listen((data) {
        if (state.isMessageActive) {
          NotificationService().sendMessageNotification();
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
    emit(state.setSuccess());
  }

  @override
  Future<void> close() async {
    await _cancelAllSubscriptions();
    changeIsMessage();
    return super.close();
  }
}