import '../service _locator.dart';
import '../../services/session_service.dart';
import '../../services/user_account_service.dart';
import 'package:social_app/features/profile/domain/useCases/profile_useCase.dart';
import 'package:social_app/features/profile/presentation/cubits/profile_cubit.dart';
import '../../../features/profile/data/data_sources/remote/firestore_profile_service.dart';
import 'package:social_app/features/profile/data/repositories_impl/firestore_profile_repository.dart';


class ProfileDependencies {
  static void register() {
    // Repository
    sl.registerLazySingleton(() =>
        FirestoreProfileRepository(
            sessionService: sl<SessionService>(),
            repository: sl<FirestoreProfileService>(),
            userAccountService: sl<UserAccountService>()));

    // UseCase
    sl.registerLazySingleton(() =>
        ProfileUseCase(
            repository: sl<FirestoreProfileRepository>(),
            userAccountService: sl<UserAccountService>()));

    // Cubit
    sl.registerFactory(() =>
        ProfileCubit(
            useCase: sl<ProfileUseCase>(),
            sessionService: sl<SessionService>(),
            userAccountService: sl<UserAccountService>()
        )
    );
  }
}