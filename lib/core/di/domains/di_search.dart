import '../service _locator.dart';
import 'package:social_app/core/services/user_account_service.dart';
import 'package:social_app/features/search/domain/useCases/search_useCase.dart';
import 'package:social_app/features/search/presentation/cubits/search_cubit.dart';
import '../../../features/search/data/data_sources/remote/firestore/firestore_search_service.dart';
import 'package:social_app/features/search/data/repositories_impl/firestore_search_repository.dart';


class SearchDependencies {
  static void register() {
    // Repository
    sl.registerLazySingleton(() =>
        FirestoreSearchRepository(repository: sl<FirestoreSearchService>()
        )
    );

    // UseCase
    sl.registerLazySingleton(() =>
        SearchUseCase(
            repository: sl<FirestoreSearchRepository>(),
            userAccountService: sl<UserAccountService>()
        )
    );

    // Cubit
    sl.registerFactory(() =>
        SearchCubit(useCase: sl<SearchUseCase>())
    );
  }
}