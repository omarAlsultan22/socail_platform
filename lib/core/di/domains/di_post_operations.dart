import '../service _locator.dart';
import '../../domain/repositories/post_repository.dart';
import 'package:social_app/core/services/data/session_service.dart';
import 'package:social_app/core/domain/use_cases/post_use_case.dart';
import 'package:social_app/core/domain/use_cases/like_use_case.dart';
import 'package:social_app/core/domain/use_cases/share_use_case.dart';
import '../../domain/data_sources/remote/firestore/post_operations.dart';
import '../../data/data_sources/remote/firestore/post_operations_impl.dart';
import 'package:social_app/core/data/repositories_impl/post_repository_impl.dart';


class PostDependencies {
  static void register() {
    //DataSource
    sl.registerLazySingleton<PostOperations>(() =>
        PostOperationsImpl(
            sessionService: sl<SessionService>()
        )
    );

    // Repository
    sl.registerLazySingleton<PostRepository>(() =>
        PostRepositoryImpl(
            repository: sl<PostOperations>()
        )
    );

    // UseCases
    sl.registerLazySingleton<PostUseCase>(() =>
        PostUseCase(
            repository: sl<PostRepository>(),
            sessionService: sl<SessionService>()
        )
    );

    sl.registerLazySingleton<LikeUseCase>(() =>
        LikeUseCase(
            repository: sl<PostRepository>()
        )
    );

    sl.registerLazySingleton<ShareUseCase>(() =>
        ShareUseCase(
            repository: sl<PostRepository>()
        )
    );
  }
}