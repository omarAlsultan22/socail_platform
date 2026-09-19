import '../../../features/post_detail/data/repositories_impl/firestore_post_detail_repository.dart';
import '../../../features/post_detail/data/data_sources/remote/firestore_post_detail_service.dart';
import '../../../features/post_detail/domain/useCases/post_detail_use_case.dart';
import '../../../features/post_detail/presentation/cubits/post_detail_cubit.dart';
import '../../services/session_service.dart';
import '../service _locator.dart';


class PostDetailDependencies {
  static void register() {
    // Repository
    sl.registerLazySingleton(() =>
        FirestorePostDetailRepository(
            repository: sl<FirestorePostDetailService>()
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
            useCase: sl<PostDetailUseCase>()
        )
    );
  }
}