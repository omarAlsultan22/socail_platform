import '../service _locator.dart';
import '../../services/domain/i_user_account_service.dart';
import 'package:social_app/core/services/data/session_service.dart';
import '../../../features/user_details/domain/repositories/user_details_repository.dart';
import '../../../features/user_details/domain/data_sources/user_details_data_source.dart';
import 'package:social_app/features/user_details/presentation/cubits/my_details_cubit.dart';
import 'package:social_app/features/user_details/domain/use_cases/user_details_use_case.dart';
import 'package:social_app/features/user_details/presentation/cubits/friends_details_cubit.dart';
import '../../../features/user_details/data/repositories_impl/user_details_repository_impl.dart';
import 'package:social_app/features/user_details/data/data_sources/user_details_data_source_impl.dart';


class UserDetailsDependencies {
  static void register() {
    //DataSource
    sl.registerLazySingleton<UserDetailsDataSource>(() =>
        UserDetailsDataSourceImpl()
    );

    //Repository
    sl.registerLazySingleton<UserDetailsRepository>(() =>
        UserDetailsRepositoryImpl(
            dataSource: sl<UserDetailsDataSource>()
        )
    );

    // UseCase
    sl.registerLazySingleton<UserDetailsUseCase>(() =>
        UserDetailsUseCase(
            sessionService: sl<SessionService>(),
            repository: sl<UserDetailsRepository>(),
            userAccountService: sl<IUserAccountService>()
        )
    );

    // Cubits
    sl.registerFactory<MyDetailsCubit>(() =>
        MyDetailsCubit(
            userDetailsUseCase: sl<UserDetailsUseCase>()
        )
    );

    sl.registerFactory<FriendsDetailsCubit>(() =>
        FriendsDetailsCubit(
            userDetailsUseCase: sl<UserDetailsUseCase>()
        )
    );
  }
}