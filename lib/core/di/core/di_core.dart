import '../../../features/public/data/services/online_status_service.dart';
import '../../../features/auth/data/network/connectivity_service.dart';
import '../../data/data_sources/remote/firebase_auth_service.dart';
import '../../data/data_sources/local/cache_helper.dart';
import '../../services/session_service.dart';
import '../service _locator.dart';


class CoreDependencies {
  static void register() {
    sl.registerLazySingleton(() => CacheHelper());
    sl.registerLazySingleton(() => SessionService());
    sl.registerLazySingleton(() => FirestoreService());
    sl.registerLazySingleton(() => OnlineStatusService());
    sl.registerLazySingleton(() => FirebaseAuthService());
    sl.registerLazySingleton(() => ConnectivityService());
    sl.registerLazySingleton(() => FirestoreHomeService());
    sl.registerLazySingleton(() => FirestoreConversationService());
  }
}