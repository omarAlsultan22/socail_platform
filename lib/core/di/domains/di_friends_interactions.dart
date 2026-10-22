import '../service _locator.dart';
import '../../services/domain/i_user_account_service.dart';
import 'package:social_app/core/services/data/session_service.dart';
import '../../domain/data_sources/remote/firestore/firestore_service.dart';
import 'package:social_app/features/main/presentation/cubits/main_cubit.dart';
import '../../../features/friendship/presentation/cubits/friendship_cubit.dart';
import '../../../features/friendship/domain/use_cases/friendship_use_case.dart';
import '../../../features/friendship/domain/repositories/friendship_repository.dart';
import 'package:social_app/features/friendship/data/repositories_impl/friendship_repository_impl.dart';


class FriendsInteractionsDependencies {
  static void register() {
    // Repository
    sl.registerLazySingleton<FriendshipRepository>(() =>
        FriendshipRepositoryImpl(
            dataSource: sl<FirestoreService>()
        )
    );

    // UseCase
    sl.registerLazySingleton<FriendshipUseCase>(() =>
        FriendshipUseCase(
            sessionService: sl<SessionService>(),
            repository: sl<FriendshipRepository>()
        )
    );

    // Cubit
    sl.registerFactory<FriendshipCubit>(() =>
        FriendshipCubit(
          mainCubit: sl<MainCubit>(),
          useCase: sl<FriendshipUseCase>(),
          userAccountService: sl<IUserAccountService>(),
        )
    );
  }
}