import '../../../features/auth/data/network/connectivity_service.dart';
import '../../../features/auth/presentation/cubits/change_email_and_password_cubit.dart';
import '../../../features/auth/domain/useCases/change_email_and_password_useCase.dart';
import '../../../features/auth/data/repositories_impl/firebase_auth_repository.dart';
import '../../../features/auth/presentation/cubits/forget_password_cubit.dart';
import '../../../features/auth/presentation/cubits/sign_in_cubit.dart';
import '../../../features/auth/presentation/cubits/sign_up_cubit.dart';
import '../../../features/auth/domain/useCases/sign_in_useCase.dart';
import '../../../features/auth/domain/useCases/sign_up_useCase.dart';
import '../../data/data_sources/remote/firebase_auth_service.dart';
import '../../data/data_sources/local/cache_helper.dart';
import '../service _locator.dart';


class AuthDependencies {
  static void register() {
    // Repositories
    sl.registerLazySingleton(() =>
        FirebaseAuthRepository(auth: sl<FirebaseAuthService>()));

    sl.registerLazySingleton(() =>
        FirebaseSignUpRepository(repository: sl<FirestoreService>()));

    // UseCases
    sl.registerLazySingleton(() =>
        SignInUseCase(
            cacheHelper: sl<CacheHelper>(),
            sessionService: ,
            authRepository: sl<FirebaseAuthRepository>()));

    sl.registerLazySingleton(() =>
        SignUpUseCase(
            cacheHelper: sl<CacheHelper>(),
            authRepository: sl<FirebaseAuthRepository>(),
            settingsRepository: sl<FirebaseSignUpRepository>()));

    sl.registerLazySingleton(() =>
        ChangeEmailAndPasswordUseCase(
            authRepository: sl<FirebaseAuthRepository>()));

    // Cubits
    sl.registerFactory(() =>
        SignInCubit(
            useCase: sl<SignInUseCase>(),
            connectivityService: sl<ConnectivityService>()));

    sl.registerFactory(() =>
        SignUpCubit(
            useCase: sl<SignUpUseCase>(),
            connectivityService: sl<ConnectivityService>()));

    sl.registerFactory(() =>
        ForgetPasswordCubit(
          repository: sl<FirebaseAuthRepository>(),
          connectivityService: sl<ConnectivityService>(),
        ));

    sl.registerFactory(() =>
        ChangeEmailAndPasswordCubit(
            useCase: sl<ChangeEmailAndPasswordUseCase>(),
            connectivityService: sl<ConnectivityService>()));
  }
}