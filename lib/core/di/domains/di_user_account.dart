import '../service _locator.dart';
import 'package:social_app/core/services/data/session_service.dart';
import '../../domain/data_sources/remote/firestore/firestore_service.dart';
import '../../../features/user_account/domain/repositories/user_account_repository.dart';
import 'package:social_app/features/user_account/domain/use_cases/user_account_use_case.dart';
import 'package:social_app/features/user_account/presentation/cubits/user_account_cubit.dart';
import 'package:social_app/features/user_account/data/repositories_impl/user_account_repository_impl.dart';


class UserAccountDependencies {
  static void register() {
    // Repository
    sl.registerLazySingleton<UserAccountRepository>(() =>
        UserAccountRepositoryImpl(
            dataSource: sl<FirestoreService>()));

    // UseCase
    sl.registerLazySingleton<UserAccountUseCase>(() =>
        UserAccountUseCase(
            sessionService: sl<SessionService>(),
            repository: sl<UserAccountRepository>()
        )
    );

    // Cubit
    sl.registerFactory<UserAccountCubit>(() =>
        UserAccountCubit(useCase: sl<UserAccountUseCase>()
        )
    );
  }
}