import '../service _locator.dart';
import '../../services/domain/i_user_account_service.dart';
import 'package:social_app/core/services/data/session_service.dart';
import 'package:social_app/core/domain/use_cases/post_use_case.dart';
import 'package:social_app/core/domain/use_cases/like_use_case.dart';
import 'package:social_app/core/domain/use_cases/share_use_case.dart';
import '../../../features/public/domain/repositories/public_repository.dart';
import '../../../features/public/domain/data_sources/public_data_source.dart';
import '../../../features/public/data/data_sources/public_data_source_impl.dart';
import 'package:social_app/features/public/domain/use_cases/public_use_case.dart';
import 'package:social_app/features/public/presentation/cubits/public_cubit.dart';
import 'package:social_app/features/public/data/repositories_impl/public_repository_impl.dart';


class PublicDependencies {
  static void register() {
    //DataSource
    sl.registerLazySingleton<PublicDataSource>(() => PublicDataSourceImpl());

    // Repository
    sl.registerLazySingleton<PublicRepository>(() =>
        PublicRepositoryImpl(
            dataSource: sl<PublicDataSource>(),
            sessionService: sl<SessionService>()
        )
    );

    // UseCase
    sl.registerLazySingleton<PublicUseCase>(() =>
        PublicUseCase(
            repository: sl<PublicRepository>(),
            sessionService: sl<SessionService>(),
            userAccountService: sl<IUserAccountService>()
        )
    );

    // Cubit
    sl.registerFactory<PublicCubit>(() =>
        PublicCubit(
          useCase: sl<PublicUseCase>(),
          postUseCase: sl<PostUseCase>(),
          likeUseCase: sl<LikeUseCase>(),
          shareUseCase: sl<ShareUseCase>(),
          sessionService: sl<SessionService>(),
          userAccountService: sl<IUserAccountService>(),
        )
    );
  }
}