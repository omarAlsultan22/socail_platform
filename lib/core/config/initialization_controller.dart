import 'firebase_options.dart';
import '../di/service _locator.dart';
import '../services/data/session_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../errors/exceptions/components_exception.dart';
import '../services/domain/i_notification_service.dart';
import '../domain/data_sources/local/cache_helper.dart';
import '../services/domain/i_online_status_service.dart';
import 'package:firebase_messaging/firebase_messaging.dart';


class InitializationController {
  static final InitializationController _instance =
  InitializationController._internal();

  factory InitializationController() => _instance;

  InitializationController._internal();

  late final CacheHelper _cacheHelper;
  late final SessionService _sessionService;
  late final INotificationService _notificationService;
  late final IOnlineStatusService _onlineStatusService;

  bool _isInitialized = false;

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

    _onlineStatusService = sl<IOnlineStatusService>();
    await _onlineStatusService.initialize();

    _notificationService = sl<INotificationService>();
    await _notificationService.initialize();

    await FirebaseMessaging.instance.setAutoInitEnabled(true);
    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
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