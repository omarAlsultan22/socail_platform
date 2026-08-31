import 'firebase_options.dart';
import '../di/service _locator.dart';
import '../services/session_service.dart';
import '../services/notification_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../data/data_sources/local/cache_helper.dart';
import '../errors/exceptions/components_exception.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../../features/public/data/services/online_status_service.dart';


class InitializationController {
  static final InitializationController _instance =
  InitializationController._internal();

  factory InitializationController() => _instance;

  InitializationController._internal();

  late final CacheHelper _cacheHelper;
  late final SessionService _sessionService;
  late final NotificationService _notificationService;
  late final OnlineStatusService _onlineStatusService;

  bool _isInitialized = false;
  RemoteMessage? _initialMessage;

  // Getters للوصول للخدمات إذا لزم الأمر
  CacheHelper get cacheHelper => _cacheHelper;
  SessionService get sessionService => _sessionService;
  NotificationService get notificationService => _notificationService;
  OnlineStatusService get onlineStatusService => _onlineStatusService;
  RemoteMessage? get initialMessage => _initialMessage;

  Future<void> _initializeServices() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    FirebaseFirestore.instance.settings = const Settings(
        persistenceEnabled: true,
        cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED
    );

    _cacheHelper = sl<CacheHelper>();
    await _cacheHelper.init();

    _sessionService = sl<SessionService>();
    await _sessionService.loadFromStorage();

    await NotificationService.setupBackgroundIsolate();

    _onlineStatusService = OnlineStatusService();
    await _onlineStatusService.initialize();

    _notificationService = NotificationService();
    await _notificationService.initialize();

    _initialMessage = await FirebaseMessaging.instance.getInitialMessage();

    if (_initialMessage != null) {
      _notificationService.handleNotification(_initialMessage!.data);
    }

    await FirebaseMessaging.instance.setAutoInitEnabled(true);
    await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
      print('Refreshed FCM token: $newToken');
    });
  }

  Future<void> init() async {
    if (_isInitialized) return;

    try {
      await _initializeServices();
    }
    catch (e) {
      throw ComponentsException(error: e);
    }
    _isInitialized = true;
  }

  Future<void> retryInit() async {
    await _initializeServices();
    _isInitialized = true;
  }

  bool get isInitialized => _isInitialized;

  void reset() {
    _isInitialized = false;
  }
}