import '../service _locator.dart';
import 'package:social_app/core/services/session_service.dart';
import 'package:social_app/core/services/user_account_service.dart';
import 'package:social_app/core/domain/use_cases/post_use_case.dart';
import 'package:social_app/core/domain/use_cases/like_use_case.dart';
import 'package:social_app/core/domain/use_cases/share_use_case.dart';
import '../../../features/user_details/domain/use_cases/user_details_use_case.dart';
import 'package:social_app/core/data/repositories_impl/firestore_post_repository.dart';
import '../../data/data_sources/remote/firestore/post_operations_remote_datasource.dart';


class PostDependencies {
  static void register() {
    // Repository
    sl.registerLazySingleton(() =>
        FirestorePostRepository(
            repository: sl<PostOperationsRemoteDataSourceImpl>()
        )
    );

    // UseCases
    sl.registerLazySingleton(() =>
        PostUseCase(
            sessionService: sl<SessionService>(),
            repository: sl<FirestorePostRepository>()
        )
    );

    sl.registerLazySingleton(() =>
        LikeUseCase(
            repository: sl<FirestorePostRepository>()
        )
    );

    sl.registerLazySingleton(() =>
        ShareUseCase(
            repository: sl<FirestorePostRepository>()
        )
    );
  }
}