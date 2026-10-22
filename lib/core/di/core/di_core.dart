import 'package:social_app/core/services/data/notification_service.dart';

import '../../data/data_sources/remote/firestore/firestore_service_impl.dart';
import '../../domain/data_sources/remote/firestore/firestore_service.dart';
import '../../data/data_sources/local/cache_helper_impl.dart';
import '../../services/data/media_upload_service.dart';
import '../../services/domain/i_media_upload_service.dart';
import '../../services/domain/i_notification_service.dart';
import '../../services/domain/i_online_status_service.dart';
import '../../services/domain/i_user_account_service.dart';
import '../../domain/data_sources/local/cache_helper.dart';
import '../../network/domain/i_connectivity_service.dart';
import '../../services/data/online_status_service.dart';
import '../../services/data/user_account_service.dart';
import '../../network/data/connectivity_service.dart';
import '../../services/data/session_service.dart';
import '../service _locator.dart';


class CoreDependencies {
  static void register() {
    sl.registerLazySingleton<CacheHelper>(() => CacheHelperImpl());
    sl.registerLazySingleton<FirestoreService>(() => FirestoreServiceImpl());
    sl.registerLazySingleton<IMediaUploadService>(() => MediaUploadService());
    sl.registerLazySingleton<INotificationService>(() => NotificationService());
    sl.registerLazySingleton<IOnlineStatusService>(() => OnlineStatusService());
    sl.registerLazySingleton<IConnectivityService>(() => ConnectivityService());
    sl.registerLazySingleton<SessionService>(() =>
        SessionService(cacheHelper: sl<CacheHelper>()
        )
    );
    sl.registerLazySingleton<IUserAccountService>(() =>
        UserAccountService(
            dataSource: sl<FirestoreService>(),
            sessionService: sl<SessionService>()
        )
    );
  }
}