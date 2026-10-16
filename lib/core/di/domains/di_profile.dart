import '../service _locator.dart';
import '../../services/session_service.dart';
import '../../services/user_account_service.dart';
import '../../domain/use_cases/like_use_case.dart';
import '../../domain/use_cases/share_use_case.dart';
import 'package:social_app/core/domain/use_cases/post_use_case.dart';
import '../../../features/profile/domain/use_cases/profile_use_case.dart';
import '../../../features/profile/data/converters/Info_data_converter.dart';
import '../../data/data_sources/remote/firestore/firestore_base_service.dart';
import 'package:social_app/features/profile/presentation/cubits/posts_cubit.dart';
import 'package:social_app/features/profile/domain/use_cases/posts_use_case.dart';
import 'package:social_app/features/profile/domain/use_cases/photos_use_case.dart';
import 'package:social_app/features/profile/domain/use_cases/videos_use_case.dart';
import 'package:social_app/features/profile/presentation/cubits/photos_cubit.dart';
import 'package:social_app/features/profile/presentation/cubits/videos_cubit.dart';
import '../../../features/user_details/domain/use_cases/user_details_use_case.dart';
import 'package:social_app/features/profile/presentation/cubits/my_profile_cubit.dart';
import 'package:social_app/features/profile/presentation/cubits/user_profile_cubit.dart';
import '../../../features/profile/data/data_sources/remote/firestore_profile_service.dart';
import 'package:social_app/features/profile/data/repositories_impl/firestore_profile_repository.dart';


class ProfileDependencies {
  static void register() {
    //DataSource
    sl.registerLazySingleton(() => FirestoreProfileService());

    //Converter
    sl.registerLazySingleton(() =>
        AccountDataConverter(
            sessionService: sl<SessionService>(),
            repository: sl<FirestoreBaseService>()
        )
    );

    // Repository
    sl.registerLazySingleton(() =>
        FirestoreProfileRepository(
            sessionService: sl<SessionService>(),
            repository: sl<FirestoreProfileService>(),
            userAccountService: sl<UserAccountService>()
        )
    );

    // UseCases
    sl.registerLazySingleton(() =>
        ProfileUseCase(
            repository: sl<FirestoreProfileRepository>(),
            userAccountService: sl<UserAccountService>(),
            accountDataConverter: sl<AccountDataConverter>()
        )
    );

    sl.registerLazySingleton(() =>
        PostsUseCase(
          repository: sl<FirestoreProfileRepository>(),
        )
    );

    sl.registerLazySingleton(() =>
        PhotosUseCase(
            repository: sl<FirestoreProfileRepository>()
        )
    );

    sl.registerLazySingleton(() =>
        VideosUseCase(
            repository: sl<FirestoreProfileRepository>()
        )
    );

    // Cubits
    sl.registerFactory(() =>
        MyProfileCubit(
            useCase: sl<ProfileUseCase>(),
            postUseCase: sl<PostUseCase>(),
            likeUseCase: sl<LikeUseCase>(),
            shareUseCase: sl<ShareUseCase>(),
            sessionService: sl<SessionService>(),
            userDetailsUseCase: sl<UserDetailsUseCase>(),
            userAccountService: sl<UserAccountService>()
        )
    );

    sl.registerFactory(() =>
        UserProfileCubit(
            useCase: sl<ProfileUseCase>(),
            postUseCase: sl<PostUseCase>(),
            likeUseCase: sl<LikeUseCase>(),
            shareUseCase: sl<ShareUseCase>(),
            sessionService: sl<SessionService>(),
            userDetailsUseCase: sl<UserDetailsUseCase>(),
            userAccountService: sl<UserAccountService>()
        )
    );

    sl.registerFactory(() =>
        PostsCubit(
            useCase: sl<PostsUseCase>(),
            postUseCase: sl<PostUseCase>(),
            likeUseCase: sl<LikeUseCase>(),
            shareUseCase: sl<ShareUseCase>(),
            userDetailsUseCase: sl<UserDetailsUseCase>(),
            userAccountService: sl<UserAccountService>()
        )
    );

    sl.registerFactory(() =>
        PhotosCubit(
            useCase: sl<PhotosUseCase>(),
            postUseCase: sl<PostUseCase>(),
            likeUseCase: sl<LikeUseCase>(),
            shareUseCase: sl<ShareUseCase>(),
            userDetailsUseCase: sl<UserDetailsUseCase>(),
            userAccountService: sl<UserAccountService>()
        )
    );

    sl.registerFactory(() =>
        VideosCubit(
            useCase: sl<VideosUseCase>(),
            postUseCase: sl<PostUseCase>(),
            likeUseCase: sl<LikeUseCase>(),
            shareUseCase: sl<ShareUseCase>(),
            userDetailsUseCase: sl<UserDetailsUseCase>(),
            userAccountService: sl<UserAccountService>()
        )
    );
  }
}