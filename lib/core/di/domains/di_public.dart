import '../service _locator.dart';
import 'package:social_app/core/services/session_service.dart';
import 'package:social_app/core/services/user_account_service.dart';
import 'package:social_app/features/public/domain/useCases/public_use_cases.dart';
import 'package:social_app/features/public/presentation/cubits/public_cubit.dart';
import '../../../features/public/data/data_sources/remote/firestore_public_service.dart';
import 'package:social_app/features/public/data/repositories_impl/firestore_public_repository.dart';


class PublicDependencies {
  static void register() {
    // Repository
    sl.registerLazySingleton(() =>
        FirestorePublicRepository(
            sessionService: sl<SessionService>(),
            repository: sl<FirestorePublicService>()
        )
    );

    // UseCase
    sl.registerLazySingleton(() =>
        PublicUseCase(
            sessionService: sl<SessionService>(),
            repository: sl<FirestorePublicRepository>(),
            userAccountService: sl<UserAccountService>()
        )
    );

    // Cubit
    sl.registerFactory(() =>
        PublicCubit(
          useCase: sl<PublicUseCase>(),
          sessionService: sl<SessionService>(),
          userAccountService: sl<UserAccountService>(),
        )
    );
  }
}