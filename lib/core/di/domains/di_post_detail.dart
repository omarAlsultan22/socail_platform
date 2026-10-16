import '../../../features/post_detail/data/repositories_impl/firestore_post_detail_repository.dart';
import '../../../features/post_detail/data/data_sources/remote/firestore_post_detail_service.dart';
import '../../../features/post_detail/domain/use_cases/post_detail_use_case.dart';
import '../../../features/post_detail/presentation/cubits/post_detail_cubit.dart';
import 'package:social_app/core/services/user_account_service.dart';
import '../../../features/user_details/domain/use_cases/user_details_use_case.dart';
import '../../domain/use_cases/share_use_case.dart';
import '../../domain/use_cases/like_use_case.dart';
import '../../domain/use_cases/post_use_case.dart';
import '../../services/session_service.dart';
import '../service _locator.dart';


class PostDetailDependencies {
  static void register() {
    //DataSource
    sl.registerLazySingleton(() => FirestorePostDetailService());

    // Repository
    sl.registerLazySingleton(() =>
        FirestorePostDetailRepository(
            sessionService: sl<SessionService>(),
            repository: sl<FirestorePostDetailService>(),
        )
    );

    // UseCase
    sl.registerLazySingleton(() =>
        PostDetailUseCase(
            sessionService: sl<SessionService>(),
            repository: sl<FirestorePostDetailRepository>()
        )
    );

    // Cubit
    sl.registerFactory(() =>
        PostDetailCubit(
            postUseCase: sl<PostUseCase>(),
            likeUseCase: sl<LikeUseCase>(),
            shareUseCase: sl<ShareUseCase>(),
            useCase: sl<PostDetailUseCase>(),
            userDetailsUseCase: sl<UserDetailsUseCase>(),
            userAccountService: sl<UserAccountService>()
        )
    );
  }
}