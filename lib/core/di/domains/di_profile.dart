import '../service _locator.dart';
import '../../services/data/session_service.dart';
import '../../domain/use_cases/like_use_case.dart';
import '../../domain/use_cases/share_use_case.dart';
import '../../services/domain/i_user_account_service.dart';
import 'package:social_app/core/domain/use_cases/post_use_case.dart';
import '../../../features/profile/domain/use_cases/profile_use_case.dart';
import '../../domain/data_sources/remote/firestore/firestore_service.dart';
import '../../../features/profile/data/converters/Info_data_converter.dart';
import '../../../features/profile/domain/repositories/profile_repository.dart';
import '../../../features/profile/domain/data_sources/profile_data_source.dart';
import 'package:social_app/features/profile/presentation/cubits/posts_cubit.dart';
import 'package:social_app/features/profile/domain/use_cases/posts_use_case.dart';
import 'package:social_app/features/profile/domain/use_cases/photos_use_case.dart';
import 'package:social_app/features/profile/domain/use_cases/videos_use_case.dart';
import 'package:social_app/features/profile/presentation/cubits/photos_cubit.dart';
import 'package:social_app/features/profile/presentation/cubits/videos_cubit.dart';
import '../../../features/profile/data/data_sources/profile_data_source_impl.dart';
import 'package:social_app/features/profile/presentation/cubits/my_profile_cubit.dart';
import 'package:social_app/features/profile/presentation/cubits/user_profile_cubit.dart';
import 'package:social_app/features/profile/data/repositories_impl/profile_repository_impl.dart';


class ProfileDependencies {
  static void register() {
    //DataSource
    sl.registerLazySingleton<ProfileDataSource>(() => ProfileDataSourceImpl());

    //Converter
    sl.registerLazySingleton<AccountDataConverter>(() =>
        AccountDataConverter(
            repository: sl<FirestoreService>(),
            sessionService: sl<SessionService>()
        )
    );

    // Repository
    sl.registerLazySingleton<ProfileRepository>(() =>
        ProfileRepositoryImpl(
            dataSource: sl<ProfileDataSource>(),
            sessionService: sl<SessionService>(),
            userAccountService: sl<IUserAccountService>()
        )
    );

    // UseCases
    sl.registerLazySingleton<ProfileUseCase>(() =>
        ProfileUseCase(
            repository: sl<ProfileRepository>(),
            userAccountService: sl<IUserAccountService>(),
            accountDataConverter: sl<AccountDataConverter>()
        )
    );

    sl.registerLazySingleton<PostsUseCase>(() =>
        PostsUseCase(
          repository: sl<ProfileRepository>(),
        )
    );

    sl.registerLazySingleton<PhotosUseCase>(() =>
        PhotosUseCase(
            repository: sl<ProfileRepository>()
        )
    );

    sl.registerLazySingleton<VideosUseCase>(() =>
        VideosUseCase(
            repository: sl<ProfileRepository>()
        )
    );

    // Cubits
    sl.registerFactory<MyProfileCubit>(() =>
        MyProfileCubit(
            useCase: sl<ProfileUseCase>(),
            postUseCase: sl<PostUseCase>(),
            likeUseCase: sl<LikeUseCase>(),
            shareUseCase: sl<ShareUseCase>(),
            sessionService: sl<SessionService>(),
            userAccountService: sl<IUserAccountService>()
        )
    );

    sl.registerFactory<UserProfileCubit>(() =>
        UserProfileCubit(
            useCase: sl<ProfileUseCase>(),
            postUseCase: sl<PostUseCase>(),
            likeUseCase: sl<LikeUseCase>(),
            shareUseCase: sl<ShareUseCase>(),
            sessionService: sl<SessionService>(),
            userAccountService: sl<IUserAccountService>()
        )
    );

    sl.registerFactory<PostsCubit>(() =>
        PostsCubit(
            useCase: sl<PostsUseCase>(),
            postUseCase: sl<PostUseCase>(),
            likeUseCase: sl<LikeUseCase>(),
            shareUseCase: sl<ShareUseCase>(),
            userAccountService: sl<IUserAccountService>()
        )
    );

    sl.registerFactory<PhotosCubit>(() =>
        PhotosCubit(
            useCase: sl<PhotosUseCase>(),
            postUseCase: sl<PostUseCase>(),
            likeUseCase: sl<LikeUseCase>(),
            shareUseCase: sl<ShareUseCase>(),
            userAccountService: sl<IUserAccountService>()
        )
    );

    sl.registerFactory<VideosCubit>(() =>
        VideosCubit(
            useCase: sl<VideosUseCase>(),
            postUseCase: sl<PostUseCase>(),
            likeUseCase: sl<LikeUseCase>(),
            shareUseCase: sl<ShareUseCase>(),
            userAccountService: sl<IUserAccountService>()
        )
    );
  }
}