import '../service _locator.dart';
import '../../services/domain/i_user_account_service.dart';
import '../../../features/search/domain/repositories/search_repository.dart';
import '../../../features/search/domain/data_sources/search_data_source.dart';
import '../../../features/search/data/data_sources/search_data_source_impl.dart';
import 'package:social_app/features/search/domain/use_cases/search_use_case.dart';
import 'package:social_app/features/search/presentation/cubits/search_cubit.dart';
import 'package:social_app/features/search/data/repositories_impl/search_repository_impl.dart';


class SearchDependencies {
  static void register() {
    //DataSource
    sl.registerLazySingleton<SearchDataSource>(() =>
        SearchDataSourceImpl()
    );

    // Repository
    sl.registerLazySingleton<SearchRepository>(() =>
        SearchRepositoryImpl(dataSource: sl<SearchDataSource>()
        )
    );

    // UseCase
    sl.registerLazySingleton<SearchUseCase>(() =>
        SearchUseCase(
            repository: sl<SearchRepository>(),
            userAccountService: sl<IUserAccountService>()
        )
    );

    // Cubit
    sl.registerFactory<SearchCubit>(() =>
        SearchCubit(useCase: sl<SearchUseCase>())
    );
  }
}