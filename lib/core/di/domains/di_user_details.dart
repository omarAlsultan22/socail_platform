import 'package:social_app/features/user_details/data/data_sources/remote/user_details_remote_data_source.dart';

import '../service _locator.dart';
import 'package:social_app/core/services/session_service.dart';
import 'package:social_app/core/services/user_account_service.dart';
import 'package:social_app/features/user_details/presentation/cubits/my_details_cubit.dart';
import 'package:social_app/features/user_details/domain/use_cases/user_details_use_case.dart';
import 'package:social_app/features/user_details/presentation/cubits/friends_details_cubit.dart';
import '../../../features/user_details/data/repositories_impl/user_details_repository_impl.dart';


class UserDetailsDependencies {
  static void register() {
    //DataSource
    sl.registerLazySingleton(() =>
        UserDetailsRemoteDataSource()
    );

    //Repository
    sl.registerLazySingleton(() =>
        UserDetailsRepositoryImpl(
            dataSourceImpl: sl<UserDetailsRemoteDataSource>()
        )
    );

    // UseCase
    sl.registerLazySingleton(() =>
        UserDetailsUseCase(
            sessionService: sl<SessionService>(),
          repository: sl<UserDetailsRepositoryImpl>(),
          userAccountService: sl<UserAccountService>()
        )
    );

    // Cubits
    sl.registerFactory(() =>
        MyDetailsCubit(
            userDetailsUseCase: sl<UserDetailsUseCase>()
        )
    );

    sl.registerFactory(() =>
        FriendsDetailsCubit(
            userDetailsUseCase: sl<UserDetailsUseCase>()
        )
    );
  }
}