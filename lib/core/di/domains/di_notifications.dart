import '../service _locator.dart';
import 'package:social_app/core/services/data/session_service.dart';
import '../../../features/notifications/domain/use_cases/notifications_use_case.dart';
import '../../../features/notifications/domain/repositories/notifications_repository.dart';
import '../../../features/notifications/domain/data_sources/notifications_data_source.dart';
import '../../../features/notifications/data/data_sources/notifications_data_source_impl.dart';
import 'package:social_app/features/notifications/presentation/cubits/notifications_cubit.dart';
import 'package:social_app/features/notifications/data/repositories_impl/notifications_repository_impl.dart';


class NotificationsDependencies {
  static void register() {
    //DataSource
    sl.registerLazySingleton<NotificationsDataSource>(() =>
        NotificationsDataSourceImpl());

    // Repository
    sl.registerLazySingleton(() =>
        NotificationsRepositoryImpl(
            dataSource: sl<NotificationsDataSource>()
        )
    );

    // UseCase
    sl.registerLazySingleton<NotificationsUseCase>(() =>
        NotificationsUseCase(
            sessionService: sl<SessionService>(),
            repository: sl<NotificationsRepository>()
        )
    );

    // Cubit
    sl.registerFactory<NotificationsCubit>(() =>
        NotificationsCubit(
            useCase: sl<NotificationsUseCase>()
        )
    );
  }
}