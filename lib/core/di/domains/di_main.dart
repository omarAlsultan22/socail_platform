import '../service _locator.dart';
import '../../services/domain/i_notification_service.dart';
import '../../services/domain/i_user_account_service.dart';
import 'package:social_app/core/services/data/session_service.dart';
import '../../../features/main/domain/use_cases/main_use_case.dart';
import '../../../features/main/domain/repositories/main_repository.dart';
import '../../../features/main/domain/data_sources/main_data_source.dart';
import '../../../features/main/data/data_sources/main_data_source_impl.dart';
import 'package:social_app/features/main/presentation/cubits/main_cubit.dart';
import 'package:social_app/features/main/data/repositories_impl/main_repository_impl.dart';


class MainDependencies {
  static void register() {
    //DataSource
    sl.registerLazySingleton<MainDataSource>(() => MainDataSourceImpl());

    // Repository
    sl.registerLazySingleton<MainRepository>(() =>
        MainRepositoryImpl(
            dataSource: sl<MainDataSource>(),
            sessionService: sl<SessionService>()
        )
    );

    // UseCase
    sl.registerLazySingleton<MainUseCases>(() =>
        MainUseCases(
            repository: sl<MainRepository>()
        )
    );

    // Cubit
    sl.registerFactory<MainCubit>(() =>
        MainCubit(
            useCase: sl<MainUseCases>(),
            sessionService: sl<SessionService>(),
            userAccountService: sl<IUserAccountService>(),
            notificationService: sl<INotificationService>()
        )
    );
  }
}