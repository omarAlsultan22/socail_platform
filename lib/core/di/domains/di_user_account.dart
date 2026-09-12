import '../service _locator.dart';
import 'package:social_app/core/services/session_service.dart';
import '../../data/data_sources/remote/firestore/firestore_base_service.dart';
import 'package:social_app/features/user_account/domain/useCases/user_account_use_case.dart';
import 'package:social_app/features/user_account/presentation/cubits/user_account_cubit.dart';
import 'package:social_app/features/user_account/data/repositories_impl/firestore_user_account_repository.dart';


class UserAccountDependencies {
  static void register() {
    // Repository
    sl.registerLazySingleton(() =>
        FirestoreUserAccountRepository(
            repository: sl<FirestoreBaseService>()));

    // UseCase
    sl.registerLazySingleton(() =>
        UserAccountUseCase(
            sessionService: sl<SessionService>(),
            repository: sl<FirestoreUserAccountRepository>()
        )
    );

    // Cubit
    sl.registerFactory(() =>
        UserAccountCubit(useCase: sl<UserAccountUseCase>()
        )
    );
  }
}