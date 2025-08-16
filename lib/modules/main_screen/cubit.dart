import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_app/models/user_model.dart';
import 'package:social_app/shared/cubit_states/cubit_states.dart';
import '../../shared/componentes/constants.dart';
import '../../shared/componentes/public_components.dart';
import '../chat_screen/chat_screen.dart';
import '../notification_service/notification_service.dart';
import '../notifications_screen/notifications_screen.dart';
import '../profile_screen/profile_screen.dart';
import '../friends_screen/friends_screen.dart';
import '../home_screen/home_screen.dart';

class MainLayoutCubit extends Cubit<CubitStates> {
  MainLayoutCubit() : super(InitialState());

  static MainLayoutCubit get(context) => BlocProvider.of(context);

  List<UserModel> suggestsList = [];
  int currentScreen = 0;
  bool isExists = false;
  final Set<String> docIdsList = {};

  final Map<String, dynamic> friendRequestsCount = {
    'counter': 0,
    'docIds': Set<String>()
  };
  final Map<String, dynamic> notificationsCount = {
    'counter': 0,
    'docIds': Set<String>()
  };
  final Map<String, dynamic> messagesCount = {
    'counter': 0,
    'docIds': Set<String>()
  };

  StreamSubscription? _notificationsSub;
  StreamSubscription? _friendRequestsSub;
  StreamSubscription? _messagesSub;
  bool isMessage = false;

  // Screens list
  final List<Widget> mainScreens = [
    HomeScreen(),
    NotificationsScreen(),
    FriendsScreen(),
    ChatScreen(),
    ProfileScreen(),
  ];

  void changeIndexScreen(int index) {
    if (currentScreen != index) {
      currentScreen = index;
      emit(ChangeIndexState());
    }
  }

  void deleteRequest() {
    if (friendRequestsCount['counter'] > 0) {
      friendRequestsCount['counter'] = friendRequestsCount['counter'] - 1;
      emit(SuccessState());
    }
  }

  void deleteNotification() {
    if (notificationsCount['counter'] > 0) {
      notificationsCount['counter'] = notificationsCount['counter'] - 1;
      emit(SuccessState());
    }
  }

  void deleteMessage() {
    if (messagesCount['counter'] > 0) {
      messagesCount['counter'] = messagesCount['counter'] - 1;
      emit(SuccessState());
    }
  }


  Future<void> checkOnAnyFriends({required String uId}) async {
    try {
      emit(LoadingState());

      final friendsRef = FirebaseFirestore.instance
          .collection('users')
          .doc(uId)
          .collection('friends');

      final friendsSnapshot = await friendsRef.get();
      isExists = friendsSnapshot.docs.isNotEmpty;

      if (!isExists) {
        final usersSnapshot = await FirebaseFirestore.instance
            .collection('users')
            .where('userId', isNotEqualTo: uId)
            .get();

        suggestsList = usersSnapshot.docs
            .map((doc) => UserModel.fromJson(doc.data()))
            .toList();
      }

      emit(SuccessState());
    } catch (error) {
      emit(ErrorState(error: error.toString()));
    }
  }


  Future<void> startListeningToCounters() async {
    await _cancelAllSubscriptions();
    isMessage = false;

    try {
      await Future.wait([
        _setupNotificationsListener(),
        _setupFriendRequestsListener(),
        _setupMessagesListener(),
      ]);

      isMessage = true;
      emit(SuccessState());
    } catch (error) {
      isMessage = true;
      emit(ErrorState(error: error.toString()));
    }
  }

  Future<void> _cancelAllSubscriptions() async {
    await _notificationsSub?.cancel();
    await _friendRequestsSub?.cancel();
    await _messagesSub?.cancel();

    _notificationsSub = null;
    _friendRequestsSub = null;
    _messagesSub = null;
  }

  Future<void> _setupNotificationsListener() async {
    notificationsCount['docIds'].clear();

    final notificationsQuery = FirebaseFirestore.instance
        .collection('notifications')
        .where('isRead', isEqualTo: false);


    final snapshot = await notificationsQuery.get();

    notificationsCount['counter'] = snapshot.size;
    notificationsCount['docIds'].addAll(
        snapshot.docs.map((doc) => doc.id).toSet());

    _notificationsSub = notificationsQuery
        .snapshots()
        .listen((snapshot) async {
      final newDocIds = Set<String>();

      for (var doc in snapshot.docs) {
        newDocIds.add(doc.id);
        final data = doc.data();
        final userModel = await getUserModelData(id: data['friendId']);
        data['friendName'] = userModel.userName;
        if (isMessage) {
          NotificationService().sendInteractionNotification(data);
        }
      }

      notificationsCount['docIds']
        ..clear()
        ..addAll(newDocIds);

      notificationsCount['counter'] = snapshot.size;
      emit(CountUpdatedState());
    });
  }

  Future<void> _setupFriendRequestsListener() async {
    friendRequestsCount['docIds'].clear();

    final requestsQuery = FirebaseFirestore.instance
        .collection('users')
        .doc(UserDetails.uId)
        .collection('requests');

    final snapshot = await requestsQuery.get();

    friendRequestsCount['counter'] = snapshot.size;
    friendRequestsCount['docIds'].addAll(
        snapshot.docs.map((doc) => doc.id).toSet());

    _friendRequestsSub = requestsQuery
        .snapshots()
        .listen((snapshot) {
      final newDocIds = Set<String>();

      for (var doc in snapshot.docs) {
        newDocIds.add(doc.id);
        if (isMessage) {
          NotificationService().sendFriendRequestNotification();
        }
      }

      friendRequestsCount['docIds']
        ..clear()
        ..addAll(newDocIds);

      friendRequestsCount['counter'] = snapshot.size;
      emit(CountUpdatedState());
    });
  }

  Future<void> _setupMessagesListener() async {
    messagesCount['docIds'].clear();
    messagesCount['counter'] = 0;

    try {
      final messagesQuery = await FirebaseFirestore.instance
          .collection('messages')
          .get();

      await _messagesSub?.cancel();

      final List<StreamSubscription> subscriptions = [];

      for (final doc in messagesQuery.docs) {
        final conversationQuery = doc.reference
            .collection('conversations')
            .where('unreadMessage', isEqualTo: true);

        final snapshot = await conversationQuery.get();

        messagesCount['counter'] =
            (messagesCount['counter'] ?? 0) + snapshot.size;
        messagesCount['docIds'].addAll(snapshot.docs.map((doc) => doc.id));

        final subscription = conversationQuery.snapshots().listen((snapshot) {
          final newDocIds = Set<String>();
          int unreadMessages = 0;

          for (var doc in snapshot.docs) {
            newDocIds.add(doc.id);
            if (doc['unreadMessage'] == true) {
              unreadMessages++;
              if (isMessage) {
                NotificationService().sendMessageNotification();
              }
            }
          }

          messagesCount['counter'] = (messagesCount['counter'] ?? 0) +
              unreadMessages -
              (messagesCount['docIds'].length - newDocIds.length);

          messagesCount['docIds']
            ..clear()
            ..addAll(newDocIds);

          emit(CountUpdatedState());
        });

        subscriptions.add(subscription);
      }

      _messagesSubs = subscriptions;
    } catch (e) {
      print('Error setting up messages listener: $e');
    }
  }

  List<StreamSubscription> _messagesSubs = [];

  void changeIsMessage() {
    isMessage = false;
    emit(SuccessState());
  }

  @override
  Future<void> close() async {
    await _cancelAllSubscriptions();
    for (final sub in _messagesSubs) {
      sub.cancel();
    }
    changeIsMessage();
    return super.close();
  }
}