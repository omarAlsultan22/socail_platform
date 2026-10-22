import '../service _locator.dart';
import 'package:social_app/core/services/data/session_service.dart';
import '../../domain/data_sources/remote/firestore/firestore_service.dart';
import '../../../features/user_info/domain/repositories/user_info_repository.dart';
import 'package:social_app/features/user_info/domain/use_cases/user_info_use_case.dart';
import 'package:social_app/features/user_info/presentation/cubits/user_info_cubit.dart';
import 'package:social_app/features/user_info/data/repositories_impl/user_info_repository_impl.dart';


class UserInfoDependencies {
  static void register() {
    // Repository
    sl.registerLazySingleton<UserInfoRepository>(() =>
        UserInfoRepositoryImpl(
            dataSource: sl<FirestoreService>()));

    // UseCase
    sl.registerLazySingleton<UserInfoUseCase>(() =>
        UserInfoUseCase(
            repository: sl<UserInfoRepository>(),
            sessionService: sl<SessionService>()));

    // Cubit
    sl.registerFactory<UserInfoCubit>(() =>
        UserInfoCubit(useCase: sl<UserInfoUseCase>()
        )
    );
  }
}