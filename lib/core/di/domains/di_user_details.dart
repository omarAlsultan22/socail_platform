import 'package:social_app/core/services/session_service.dart';

import '../service _locator.dart';
import 'package:social_app/core/services/user_account_service.dart';
import 'package:social_app/features/user_details/domain/use_cases/user_details_use_case.dart';
import 'package:social_app/features/user_details/presentation/cubits/user_details_cubit.dart';


class UserDetailsDependencies {
  static void register() {
    // UseCase
    sl.registerLazySingleton(() =>
        UserDetailsUseCase(
            sessionService: sl<SessionService>(),
            userAccountService: sl<UserAccountService>()
        )
    );

    // Cubit
    sl.registerFactory(() =>
        UserDetailsCubit(
            userDetailsUseCase: sl<UserDetailsUseCase>()
        )
    );
  }
}