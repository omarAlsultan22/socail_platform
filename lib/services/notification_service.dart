import 'dart:async';
import 'dart:convert';
import '../main.dart';
import 'package:flutter/material.dart';
import '../modules/main_screen/cubit.dart';
import '../shared/constants/user_details.dart';
import '../modules/main_screen/main_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:social_app/models/notification_model.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../layout/notifications_layout/notifications_layout.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';


class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  StreamSubscription? _interactionsSubscription;
  StreamSubscription? _friendRequestsSubscription;
  StreamSubscription? _messagesSub;
  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;

    try {
      await _setupFirebase();
      await _setupLocalNotifications();
      _setupInteractedMessage();
      await _setupBackgroundMessageHandler();
      //await setupFirestoreListeners();
      _initialized = true;
    } catch (e) {
      debugPrint('Error initializing NotificationService: $e');
      rethrow;
    }
  }

  Future<void> _setupFirebase() async {
    try {
      NotificationSettings settings = await _firebaseMessaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: true,
      );

      debugPrint('User granted permission: ${settings.authorizationStatus}');

      final token = await _firebaseMessaging.getToken();
      if (token != null) {
        await _saveTokenToFirestore(token);
      }

      _firebaseMessaging.onTokenRefresh.listen(_saveTokenToFirestore);
    } catch (e) {
      debugPrint('Error setting up Firebase: $e');
      rethrow;
    }
  }

  Future<void> _saveTokenToFirestore(String token) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(UserDetails.uId)
          .update({'fcmToken': token});
      debugPrint('FCM token saved successfully');
    } catch (e) {
      debugPrint('Error saving FCM token: $e');
      rethrow;
    }
  }

  Future<void> _setupLocalNotifications() async {
    try {
      const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');

      final DarwinInitializationSettings initializationSettingsIOS =
      DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
        notificationCategories: [
          DarwinNotificationCategory(
            'social_app_category',
            actions: <DarwinNotificationAction>[
              DarwinNotificationAction.plain(
                'id_1',
                'View',
                options: <DarwinNotificationActionOption>{
                  DarwinNotificationActionOption.foreground,
                },
              ),
            ],
          ),
        ],
      );

      final InitializationSettings initializationSettings =
      InitializationSettings(
        android: initializationSettingsAndroid,
        iOS: initializationSettingsIOS,
        macOS: initializationSettingsIOS,
      );

      await _flutterLocalNotificationsPlugin.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: (NotificationResponse details) {
          if (details.payload != null) {
            handleNotification(jsonDecode(details.payload!));
          }
        },
      );
    } catch (e) {
      debugPrint('Error setting up local notifications: $e');
      rethrow;
    }
  }

  void _setupInteractedMessage() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('Got a message whilst in the foreground!');
      debugPrint('Message data: ${message.data}');

      if (message.notification != null) {
        debugPrint('Message also contained a notification: ${message.notification}');
        _showNotification(message);
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint('Message opened from background: ${message.data}');
      handleNotification(message.data);
    });
  }

  Future<void> _setupBackgroundMessageHandler() async {
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }

  static Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
    debugPrint("Handling a background message: ${message.messageId}");
    await handleBackgroundNotification(message);
  }

  static Future<void> handleBackgroundNotification(RemoteMessage message) async {
    await setupBackgroundIsolate();
    final notificationService = NotificationService();
    await notificationService.initialize();
    notificationService.handleNotification(message.data);
  }

  void handleNotification(Map<String, dynamic> data) {
    try {
      final type = data['type'];
      debugPrint('Handling notification of type: $type');

      switch (type) {
        case 'friends_request':
          navigatorKey.currentState?.push(
            MaterialPageRoute(
                builder: (context) {
                  MainLayoutCubit.get(context).changeIndexScreen(2);
                  return MainScreen();
                }
            ),
          );
          break;
        case 'thumb_up':
        case 'mode_comment':
        case 'share':
          navigatorKey.currentState?.push(
            MaterialPageRoute(
                builder: (context) {
                  MainLayoutCubit.get(context).changeIndexScreen(1);
                  return ShowPost(notificationsModel: NotificationsModel(
                      userId: data['data']['userId'] ?? '',
                      userAction: data['data']['userAction'] ?? '',
                      iconName: data['data']['iconName'] ?? '',
                      friendId: data['data']['friendId'] ?? '',
                      postId: data['data']['postId'] ?? '',
                      docId: data['data']['docId'] ?? ''));
                }
            ),
          );
          break;
        default:
          debugPrint('Unknown notification type: $type');
      }
    } catch (e) {
      debugPrint('Error handling notification: $e');
    }
  }

  Future<void> _showNotification(RemoteMessage message) async {
    try {
      final androidPlatformChannelSpecifics = AndroidNotificationDetails(
        'social_app_channel',
        'Social App Notifications',
        channelDescription: 'Channel for social app notifications',
        importance: Importance.max,
        priority: Priority.high,
        showWhen: true,
        enableVibration: true,
        playSound: true,
      );

      final darwinNotificationDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      final notificationDetails = NotificationDetails(
        android: androidPlatformChannelSpecifics,
        iOS: darwinNotificationDetails,
      );

      await _flutterLocalNotificationsPlugin.show(
        message.hashCode,
        message.notification?.title ?? 'New Notification',
        message.notification?.body ?? 'You have a new notification',
        notificationDetails,
        payload: jsonEncode(message.data),
      );
    } catch (e) {
      debugPrint('Error showing notification: $e');
    }
  }

  Future<void> sendInteractionNotification(Map<String, dynamic> data) async {
    try {
      final type = data['iconName'];
      final senderName = data['friendName'];

      String title = 'New';
      String body = '';

      switch (type) {
        case 'thumb_up':
          title = 'New like';
          body = '$senderName liked your post';
          break;
        case 'mode_comment':
          title = 'New comment';
          body = '$senderName commented on your post';
          break;
        case 'share':
          title = 'New share';
          body = '$senderName shared your post';
          break;
        default:
          title = 'New notification';
          body = 'You have a new notification from $senderName';
      }

      await _showLocalNotification(
        title: title,
        body: body,
        payload: {
          'type': type,
          'data': data,
        },
      );
    } catch (e) {
      debugPrint('Error sending interaction notification: $e');
    }
  }

  Future<void> sendFriendRequestNotification() async {
    try {
      await _showLocalNotification(
        title: 'New friend request',
        body: 'Tap to view the request',
        payload: {
          'type': 'friend_request',
        },
      );
    } catch (e) {
      debugPrint('Error sending friend request notification: $e');
    }
  }

  Future<void> sendMessageNotification() async {
    try {
      await _showLocalNotification(
        title: 'New message',
        body: 'Tap to view the message',
        payload: {
          'type': 'message',
        },
      );
    } catch (e) {
      debugPrint('Error sending message notification: $e');
    }
  }

  Future<void> _showLocalNotification({
    required String title,
    required String body,
    required Map<String, dynamic> payload,
  }) async {
    try {
      final processedPayload = _processPayload(payload);

      const androidPlatformChannelSpecifics = AndroidNotificationDetails(
        'social_app_channel',
        'Social App Notifications',
        channelDescription: 'Channel for social app notifications',
        importance: Importance.max,
        priority: Priority.high,
        showWhen: true,
        enableVibration: true,
        playSound: true,
      );

      const darwinNotificationDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const notificationDetails = NotificationDetails(
        android: androidPlatformChannelSpecifics,
        iOS: darwinNotificationDetails,
      );

      await _flutterLocalNotificationsPlugin.show(
        DateTime.now().millisecondsSinceEpoch ~/ 1000,
        title,
        body,
        notificationDetails,
        payload: jsonEncode(processedPayload),
      );
    } catch (e) {
      debugPrint('Error showing local notification: $e');
      debugPrint('Stack trace: ${e.toString()}');
    }
  }

  Map<String, dynamic> _processPayload(Map<String, dynamic> payload) {
    final processed = <String, dynamic>{};

    payload.forEach((key, value) {
      if (value is Timestamp) {
        processed[key] = value.toDate().toString();
      } else if (value is Map<String, dynamic>) {
        processed[key] = _processPayload(value);
      } else if (value is List) {
        processed[key] = value.map((item) {
          if (item is Map<String, dynamic>) {
            return _processPayload(item);
          } else if (item is Timestamp) {
            return item.toDate().toString();
          }
          return item;
        }).toList();
      } else {
        processed[key] = value;
      }
    });

    return processed;
  }

  static Future<void> setupBackgroundIsolate() async {
    WidgetsFlutterBinding.ensureInitialized();

    await Firebase.initializeApp();

    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    final DarwinInitializationSettings initializationSettingsIOS =
    DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    final InitializationSettings initializationSettings =
    InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await FlutterLocalNotificationsPlugin().initialize(initializationSettings);
  }

  Future<void> dispose() async {
    await _interactionsSubscription?.cancel();
    await _friendRequestsSubscription?.cancel();
    await _messagesSub?.cancel();
    _initialized = false;
  }
}