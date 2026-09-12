import '../service _locator.dart';
import 'package:social_app/features/notifications/domain/useCases/notifications_useCase.dart';
import 'package:social_app/features/notifications/presentation/cubits/notifications_cubit.dart';
import '../../../features/notifications/data/data_sources/remote/firestore_notifications_service.dart';
import 'package:social_app/features/notifications/data/repositories_impl/firestore_notifications_repository.dart';


class NotificationsDependencies {
  static void register() {
    // Repository
    sl.registerLazySingleton(() =>
        FirestoreNotificationsRepository(
            repository: sl<FirestoreNotificationsService>()
        )
    );

    // UseCase
    sl.registerLazySingleton(() =>
        NotificationsUseCase(
            repository: sl<FirestoreNotificationsRepository>()));

    // Cubit
    sl.registerFactory(() =>
        NotificationsCubit(useCase: sl<NotificationsUseCase>()
        )
    );
  }
}