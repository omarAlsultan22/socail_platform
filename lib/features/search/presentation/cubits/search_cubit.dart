import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_app/core/data/models/user_model.dart';
import '../../../../core/presentation/states/app_sub_states.dart';
import '../../../../core/presentation/mixins/error_handler_mixin.dart';
import 'package:social_app/features/search/domain/useCases/search_useCase.dart';
import 'package:social_app/features/search/presentation/states/search_state.dart';


class SearchCubit extends Cubit<SearchState> with ErrorHandlerMixin<SearchState> {
  final SearchUseCase _useCase;

  SearchCubit({required SearchUseCase useCase})
      : _useCase = useCase,
        super(SearchState.initial());

  static SearchCubit get(context) => BlocProvider.of(context);

  List<UserModel> searchDataList = [];

  Future<void> getDataSearch({required String query}) async {
    emit(state.copyWith(subState: LoadingState()));
    try {
      final searchDataList = await _useCase.execute(query: query);
      emit(state.copyWith(
          subState: SuccessState(), firstModel: searchDataList));
    } catch (e, stackTrace) {
      handleError(e, stackTrace,
          onError: (failure) =>
              state.copyWith(
                  subState: ErrorState(failure: failure)
              )
      );
    }
  }

  void clearSearch() {
    emit(state.copyWith(subState: InitialState(), firstModel: []));
  }
}

