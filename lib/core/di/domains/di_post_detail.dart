import '../../../features/post_detail/data/repositories_impl/post_detail_repository_impl.dart';
import '../../../features/post_detail/data/data_sources/post_detail_data_source_impl.dart';
import '../../../features/post_detail/domain/data_sources/post_detail_data_source.dart';
import '../../../features/post_detail/domain/repositories/post_detail_repository.dart';
import '../../../features/user_details/domain/use_cases/user_details_use_case.dart';
import '../../../features/post_detail/domain/use_cases/post_detail_use_case.dart';
import '../../../features/post_detail/presentation/cubits/post_detail_cubit.dart';
import '../../services/domain/i_user_account_service.dart';
import '../../domain/use_cases/share_use_case.dart';
import '../../domain/use_cases/like_use_case.dart';
import '../../domain/use_cases/post_use_case.dart';
import '../../services/data/session_service.dart';
import '../service _locator.dart';


class PostDetailDependencies {
  static void register() {
    //DataSource
    sl.registerLazySingleton<PostDetailDataSource>(() =>
        PostDetailDataSourceImpl());

    // Repository
    sl.registerLazySingleton<PostDetailRepository>(() =>
        PostDetailRepositoryImpl(
          sessionService: sl<SessionService>(),
          dataSource: sl<PostDetailDataSource>(),
        )
    );

    // UseCase
    sl.registerLazySingleton<PostDetailUseCase>(() =>
        PostDetailUseCase(
            sessionService: sl<SessionService>(),
            repository: sl<PostDetailRepository>()
        )
    );

    // Cubit
    sl.registerFactory<PostDetailCubit>(() =>
        PostDetailCubit(
            postUseCase: sl<PostUseCase>(),
            likeUseCase: sl<LikeUseCase>(),
            shareUseCase: sl<ShareUseCase>(),
            useCase: sl<PostDetailUseCase>(),
            userAccountService: sl<IUserAccountService>()
        )
    );
  }
}