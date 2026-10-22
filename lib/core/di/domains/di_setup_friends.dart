import '../service _locator.dart';
import 'package:social_app/core/services/data/session_service.dart';
import '../../domain/data_sources/remote/firestore/firestore_service.dart';
import '../../../features/setup_friends/domain/repositories/setup_friends_repository.dart';
import 'package:social_app/features/setup_friends/domain/use_cases/setup_friends_use_case.dart';
import 'package:social_app/features/setup_friends/presentation/cubits/setup_friends_cubit.dart';
import 'package:social_app/features/setup_friends/data/repositories_impl/setup_friends_repository_impl.dart';


class SetupFriendsDependencies {
  static void register() {
    // Repository
    sl.registerLazySingleton<SetupFriendsRepository>(() =>
        SetupFriendsRepositoryImpl(
            dataSource: sl<FirestoreService>(),
            sessionService: sl<SessionService>()
        )
    );

    // UseCase
    sl.registerLazySingleton<SetupFriendsUseCase>(() =>
        SetupFriendsUseCase(
            repository: sl<SetupFriendsRepository>()
        )
    );

    // Cubit
    sl.registerFactory<SetupFriendsCubit>(() =>
        SetupFriendsCubit(useCase: sl<SetupFriendsUseCase>()
        )
    );
  }
}