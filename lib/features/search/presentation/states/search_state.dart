import '../../../../core/data/models/user_model.dart';
import '../../../../core/errors/exceptions/base/app_exception.dart';
import 'package:social_app/core/presentation/states/app_sub_states.dart';
import '../../../../core/presentation/states/base/main_app_sub_state.dart';
import 'package:social_app/features/search/data/models/search_success_state.dart';
import 'package:social_app/core/presentation/states/base/main_app_sup_state.dart';


class SearchState extends MainAppSupState {
  final String query;
  final List<UserModel> searchDataList;

  const SearchState({
    required this.query,
    required super.subState,
    required this.searchDataList,
  });

  factory SearchState.initial(){
    return SearchState(
        query: '',
        searchDataList: [],
        subState: InitialState()
    );
  }

  SearchState copyWith({
    String? query,
    MainAppSubState? subState,
    List<UserModel>? searchDataList
  }) {
    return SearchState(
      query:  query ?? this.query,
      subState: subState ?? this.subState,
      searchDataList: searchDataList ?? this.searchDataList,
    );
  }

  @override
  SearchSuccessState get dataModels =>
      SearchSuccessState(
          query: query,
          searchDataList: searchDataList
      );

  @override
  R when<R>({
    required R Function() onInitial,
    required R Function() onLoading,
    required R Function(SearchSuccessState) onLoaded,
    required R Function(AppException) onError
  }) {
    return subState.when(
        onInitial: onInitial,
        onLoading: onLoading,
        onLoaded: () =>
            onLoaded.call(dataModels),
        onError: (failure) => onError.call(failure));
  }
}