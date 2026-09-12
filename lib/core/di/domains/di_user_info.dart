import '../service _locator.dart';
import 'package:social_app/core/services/session_service.dart';
import '../../data/data_sources/remote/firestore/firestore_base_service.dart';
import 'package:social_app/features/user_info/domain/useCases/user_info_use_case.dart';
import 'package:social_app/features/user_info/presentation/cubits/user_info_cubit.dart';
import 'package:social_app/features/user_info/data/repositories_impl/firestore_user_info_repository.dart';


class UserInfoDependencies {
  static void register() {
    // Repository
    sl.registerLazySingleton(() =>
        FirestoreUserInfoRepository(
            repository: sl<FirestoreBaseService>()));

    // UseCase
    sl.registerLazySingleton(() =>
        UserInfoUseCase(
            repository: sl<FirestoreUserInfoRepository>(),
            sessionService: sl<SessionService>()));

    // Cubit
    sl.registerFactory(() =>
        UserInfoCubit(useCase: sl<UserInfoUseCase>()
        )
    );
  }
}