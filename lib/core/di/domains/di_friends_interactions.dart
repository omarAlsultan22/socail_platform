import '../service _locator.dart';
import 'package:social_app/core/services/session_service.dart';
import 'package:social_app/core/services/user_account_service.dart';
import '../../data/data_sources/remote/firestore/firestore_base_service.dart';
import '../../../features/friends_interactions/domain/useCases/friends_interactions_useCase.dart';
import '../../../features/friends_interactions/presentation/cubits/friends_interactions_cubit.dart';
import '../../../features/friends_interactions/data/repositories_impl/firestore_friends_interactions_repository.dart';


class FriendsInteractionsDependencies {
  static void register() {
    // Repository
    sl.registerLazySingleton(() =>
        FirebaseFriendsInteractionsRepository(
            repository: sl<FirestoreBaseService>()
        )
    );

    // UseCase
    sl.registerLazySingleton(() =>
        FriendsInteractionsUseCase(
            sessionService: sl<SessionService>(),
            repository: sl<FirebaseFriendsInteractionsRepository>()
        )
    );

    // Cubit
    sl.registerFactory(() =>
        FriendsInteractionsCubit(
            useCase: sl<FriendsInteractionsUseCase>(),
            userAccountService: sl<UserAccountService>()
        )
    );
  }
}