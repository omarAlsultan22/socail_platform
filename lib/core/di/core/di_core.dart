import '../../../features/search/data/data_sources/remote/firestore/firestore_search_service.dart';
import '../../../features/profile/data/data_sources/remote/firestore_profile_service.dart';
import '../../../features/public/data/data_sources/remote/firestore_public_service.dart';
import '../../data/data_sources/remote/firestore/firestore_base_service.dart';
import '../../../features/public/data/services/online_status_service.dart';
import '../../../features/auth/data/network/connectivity_service.dart';
import '../../data/data_sources/remote/firebase_auth_service.dart';
import '../../data/data_sources/local/cache_helper.dart';
import '../../services/user_account_service.dart';
import '../../services/session_service.dart';
import '../service _locator.dart';


class CoreDependencies {
  static void register() {
    sl.registerLazySingleton(() => CacheHelper());
    sl.registerLazySingleton(() => OnlineStatusService());
    sl.registerLazySingleton(() => FirebaseAuthService());
    sl.registerLazySingleton(() => ConnectivityService());
    sl.registerLazySingleton(() => FirestoreBaseService());
    sl.registerLazySingleton(() => FirestoreSearchService());
    sl.registerLazySingleton(() => FirestorePublicService());
    sl.registerLazySingleton(() => FirestoreProfileService());
    sl.registerLazySingleton(() =>
        UserAccountService(
            sessionService: sl<SessionService>(),
            repository: sl<FirestoreBaseService>()
        )
    );
    sl.registerLazySingleton(() =>
        SessionService(cacheHelper: sl<CacheHelper>()));
  }
}