import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import '../../di/service _locator.dart';
import '../../navigation/navigation_keys.dart';
import '../domain/i_notification_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:social_app/core/services/data/session_service.dart';
import '../../../features/main/presentation/cubits/main_cubit.dart';
import '../../../features/main/presentation/screens/main_screen.dart';
import '../../domain/data_sources/remote/firestore/firestore_service.dart';
import '../../../features/notifications/data/models/notification_model.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../../../features/post_detail/presentation/screens/post_detail_screen.dart';


class NotificationService implements INotificationService {
  // Singleton (نُبقيه للتوافق مع الكود الأصلي).
  static final NotificationService _instance = NotificationService._internal();

  factory NotificationService() => _instance;

  NotificationService._internal();

  // ---- الحقول الأصلية ----
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  StreamSubscription? _messagesSubscription;

  MainCubit? _cubit;
  bool _initialized = false;
  late FirestoreService _dataSource;
  late SessionService _sessionService;

  // ==================== العقد العام ====================

  @override
  Future<void> initialize() async {
    if (_initialized) return;
    try {
      _initializeDependencies();
      await _setupFirebase();
      await _setupLocalNotifications();
      _setupInteractedMessage();
      await _setupBackgroundMessageHandler();
      _initialized = true;
    } catch (e) {
      debugPrint('Error initializing NotificationService: $e');
      rethrow;
    }
  }

  @override
  Future<void> handleInitialMessage() async {
    final initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      handleNotification(initialMessage.data);
    }
  }

  @override
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

  @override
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

  @override
  Future<void> subscribeToTopic(String topic) async {
    await _firebaseMessaging.subscribeToTopic(topic);
  }

  @override
  Future<void> unsubscribeFromTopic(String topic) async {
    await _firebaseMessaging.unsubscribeFromTopic(topic);
  }

  @override
  void handleNotification(Map<String, dynamic> dataMap) {
    try {
      final type = dataMap['type'] ;
      final data = dataMap['data'] as Map<String, dynamic>? ?? {};

      debugPrint('Handling notification of type: $type');

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (NavigationKeys.currentState == null) {
          debugPrint('Navigator not ready yet');
          return;
        }

        _cubit ??= MainCubit.get(NavigationKeys.context);

        switch (type) {
          case 'friend_request':
            NavigationKeys.currentState?.push(
              MaterialPageRoute(
                  builder: (context) {
                    _cubit!.changeIndexScreen(2);
                    return MainScreen();
                  }
              ),
            );
            break;
          case 'thumb_up':
          case 'mode_comment':
          case 'share':
            NavigationKeys.currentState?.push(
              MaterialPageRoute(
                  builder: (context) {
                    _cubit!.changeIndexScreen(1);
                    return PostDetailScreen(
                        notificationsModel: NotificationsModel(
                            myId: data['userId'] ?? '',
                            userAction: data['userAction'] ?? '',
                            iconName: data['iconName'] ?? '',
                            friendId: data['friendId'] ?? '',
                            postId: data['postId'] ?? '',
                            docId: data['docId'] ?? ''));
                  }
              ),
            );
            break;
          default:
            debugPrint('Unknown notification type: $type');
        }
      });
    } catch (e) {
      debugPrint('Error handling notification: $e');
    }
  }

  // ==================== تفاصيل التنفيذ (خاصة) ====================

  void _initializeDependencies() {
    _dataSource = sl<FirestoreService>();
    _sessionService = sl<SessionService>();
  }

  Future<void> _setupFirebase() async {
    await _firebaseMessaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    final token = await _firebaseMessaging.getToken();
    debugPrint('FCM Token: $token');

    if (token != null) {
      await _saveTokenToFirestore(token);
    }

    _firebaseMessaging.onTokenRefresh.listen(_saveTokenToFirestore);
  }

  Future<void> _saveTokenToFirestore(String token) async {
    try {
      await _dataSource.updateDoc(
          collectionPath: 'users',
          data: {'fcmToken': token},
          docId: _sessionService.currentUid
      );
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

      await _flutterLocalNotificationsPlugin.initialize(settings: initializationSettings,
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
    _messagesSubscription =
        FirebaseMessaging.onMessage.listen((RemoteMessage message) {
          debugPrint('Got a message whilst in the foreground!');
          debugPrint('Message data: ${message.data}');

          if (message.notification != null) {
            debugPrint(
                'Message also contained a notification: ${message
                    .notification}');
            _showNotification(message);
          }
        });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint('Message opened from background: ${message.data}');
      handleNotification(message.data);
    });
  }

  Future<void> _setupBackgroundMessageHandler() async {
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  }

  Future<void> _showNotification(RemoteMessage message) async {
    try {
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
        id: message.hashCode,
        title: message.notification?.title ?? 'New Notification',
        body: message.notification?.body ?? 'You have a new notification',
        notificationDetails: notificationDetails,
        payload: jsonEncode(message.data),
      );
    } catch (e) {
      debugPrint('Error showing notification: $e');
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
        id: DateTime
            .now()
            .millisecondsSinceEpoch ~/ 1000,
        title: title,
        body: body,
        notificationDetails: notificationDetails,
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
      if (value is DateTime) {
        processed[key] = value.toIso8601String();
      } else if (value is Timestamp) {
        processed[key] = value.toDate().toIso8601String();
      } else if (value is Map<String, dynamic>) {
        processed[key] = _processPayload(value);
      } else if (value is List) {
        processed[key] = value.map((item) {
          if (item is Map<String, dynamic>) {
            return _processPayload(item);
          } else if (item is Timestamp) {
            return item.toDate().toIso8601String();
          } else if (item is DateTime) {
            return item.toIso8601String();
          }
          return item;
        }).toList();
      } else {
        processed[key] = value;
      }
    });
    return processed;
  }

  @override
  Future<void> handleBackgroundNotification(RemoteMessage message) async {
    await _setupBackgroundIsolate();
    handleNotification(message.data);
  }

  static Future<void> _setupBackgroundIsolate() async {
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

    await FlutterLocalNotificationsPlugin().initialize(settings: initializationSettings);
  }
}

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint("Handling a background message: ${message.messageId}");
  await NotificationService().handleBackgroundNotification(message);
}