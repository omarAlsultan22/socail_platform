import '../service _locator.dart';
import 'package:social_app/core/services/session_service.dart';
import 'package:social_app/core/services/user_account_service.dart';
import 'package:social_app/core/domain/use_cases/post_use_case.dart';
import 'package:social_app/core/domain/use_cases/like_use_case.dart';
import 'package:social_app/core/domain/use_cases/share_use_case.dart';
import 'package:social_app/features/user_details/domain/use_cases/user_details_use_case.dart';
import 'package:social_app/features/public/domain/use_cases/public_use_cases.dart';
import 'package:social_app/features/public/presentation/cubits/public_cubit.dart';
import '../../../features/public/data/data_sources/remote/firestore_public_service.dart';
import 'package:social_app/features/public/data/repositories_impl/firestore_public_repository.dart';


class PublicDependencies {
  static void register() {
    // Repository
    sl.registerLazySingleton(() =>
        FirestorePublicRepository(
            sessionService: sl<SessionService>(),
            repository: sl<FirestorePublicService>()
        )
    );

    // UseCase
    sl.registerLazySingleton(() =>
        PublicUseCase(
            sessionService: sl<SessionService>(),
            repository: sl<FirestorePublicRepository>(),
            userAccountService: sl<UserAccountService>()
        )
    );

    // Cubit
    sl.registerFactory(() =>
        PublicCubit(
          useCase: sl<PublicUseCase>(),
          postUseCase: sl<PostUseCase>(),
          likeUseCase: sl<LikeUseCase>(),
          shareUseCase: sl<ShareUseCase>(),
          sessionService: sl<SessionService>(),
          userDetailsUseCase: sl<UserDetailsUseCase>(),
          userAccountService: sl<UserAccountService>(),
        )
    );
  }
}