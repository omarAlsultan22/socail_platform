import '../service _locator.dart';
import 'package:social_app/core/services/session_service.dart';
import '../../data/data_sources/remote/firestore/firestore_base_service.dart';
import 'package:social_app/features/setup_friends/domain/useCases/setup_friends_useCase.dart';
import 'package:social_app/features/setup_friends/presentation/cubits/setup_friends_cubit.dart';
import 'package:social_app/features/setup_friends/data/repositories_impl/firestore_setup_friends_repository.dart';


class SetupFriendsDependencies {
  static void register() {
    // Repository
    sl.registerLazySingleton(() =>
        FirestoreSetupFriendsRepository(
            sessionService: sl<SessionService>(),
            repository: sl<FirestoreBaseService>()
        )
    );

    // UseCase
    sl.registerLazySingleton(() =>
        SetupFriendsUseCase(
            repository: sl<FirestoreSetupFriendsRepository>()
        )
    );

    // Cubit
    sl.registerFactory(() =>
        SetupFriendsCubit(useCase: sl<SetupFriendsUseCase>()
        )
    );
  }
}