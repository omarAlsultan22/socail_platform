import '../../data/data_sources/remote/firestore/firestore_base_service.dart';
import '../../../features/public/data/services/online_status_service.dart';
import '../../../features/auth/data/network/connectivity_service.dart';
import '../../data/data_sources/local/cache_helper.dart';
import '../../services/user_account_service.dart';
import '../../services/session_service.dart';
import '../service _locator.dart';


class CoreDependencies {
  static void register() {
    sl.registerLazySingleton(() => CacheHelper());
    sl.registerLazySingleton(() => OnlineStatusService());
    sl.registerLazySingleton(() => ConnectivityService());
    sl.registerLazySingleton(() => FirestoreBaseService());
    sl.registerLazySingleton(() =>
        SessionService(cacheHelper: sl<CacheHelper>()
        )
    );
    sl.registerLazySingleton(() =>
        UserAccountService(
            sessionService: sl<SessionService>(),
            repository: sl<FirestoreBaseService>()
        )
    );
  }
}