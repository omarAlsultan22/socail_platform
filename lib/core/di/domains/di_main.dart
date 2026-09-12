import '../service _locator.dart';
import '../../services/user_account_service.dart';
import 'package:social_app/core/services/session_service.dart';
import 'package:social_app/core/services/notification_service.dart';
import 'package:social_app/features/main/domain/useCases/main_use_case.dart';
import 'package:social_app/features/main/presentation/cubits/main_cubit.dart';
import '../../../features/main/data/data_sources/remote/firestore_main_service.dart';
import 'package:social_app/features/main/data/repositories_impl/firestore_main_repository.dart';


class MainDependencies {
  static void register() {
    // Repository
    sl.registerLazySingleton(() =>
        FirestoreMainRepository(
            sessionService: sl<SessionService>(),
            repository: sl<FirestoreMainService>()
        )
    );

    // UseCase
    sl.registerLazySingleton(() =>
        MainUseCases(
            repository: sl<FirestoreMainRepository>()
        )
    );

    // Cubit
    sl.registerFactory(() =>
        MainCubit(
            useCase: sl<MainUseCases>(),
            notificationService: NotificationService(),
            userAccountService: sl<UserAccountService>()
        )
    );
  }
}