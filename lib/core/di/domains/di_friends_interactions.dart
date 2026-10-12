import '../service _locator.dart';
import 'package:social_app/core/services/session_service.dart';
import 'package:social_app/core/services/user_account_service.dart';
import '../../data/data_sources/remote/firestore/firestore_base_service.dart';
import 'package:social_app/features/main/presentation/cubits/main_cubit.dart';
import '../../../features/friendship/presentation/cubits/friendship_cubit.dart';
import '../../../features/friendship/domain/use_cases/friendship_use_case.dart';
import 'package:social_app/features/friendship/data/repositories_impl/firestore_friendship_repository.dart';


class FriendsInteractionsDependencies {
  static void register() {
    // Repository
    sl.registerLazySingleton(() =>
        FirestoreFriendshipRepository(
            repository: sl<FirestoreBaseService>()
        )
    );

    // UseCase
    sl.registerLazySingleton(() =>
        FriendshipUseCase(
            sessionService: sl<SessionService>(),
            repository: sl<FirestoreFriendshipRepository>()
        )
    );

    // Cubit
    sl.registerFactory(() =>
        FriendshipCubit(
          mainCubit: sl<MainCubit>(),
          useCase: sl<FriendshipUseCase>(),
          userAccountService: sl<UserAccountService>(),
        )
    );
  }
}