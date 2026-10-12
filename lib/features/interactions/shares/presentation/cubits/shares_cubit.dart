import 'dart:async';
import '../states/shares_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/use_cases/get_shares_stream_use_case.dart';
import '../../../../../core/presentation/states/app_sub_states.dart';
import '../../../../../core/presentation/mixins/error_handler_mixin.dart';


class SharesCubit extends Cubit<SharesState> with ErrorHandlerMixin<SharesState> {
  final GetSharesStreamUseCase getSharesStreamUseCase;

  SharesCubit({
    required this.getSharesStreamUseCase,
  }) : super(SharesState.initial());

  static SharesCubit get(context) => BlocProvider.of(context);

  StreamSubscription? _sharesSubscription;

  void listenToShares(String? docId) {
    _sharesSubscription?.cancel();

    if (docId == null || docId.isEmpty) {
      emit(state.copyWith(subState: InitialState()));
      return;
    }

    emit(state.copyWith(subState: LoadingState()));

    try {
      _sharesSubscription = getSharesStreamUseCase(docId).listen(
            (sharesList) {
          emit(state.copyWith(
              sharesList: sharesList,
              subState: SuccessState()
          )
          );
        },
      );
    }
    catch (e, stackTrace) {
      handleError(e, stackTrace, onError: (failure) =>
          state.copyWith(subState: ErrorState(failure: failure)
          )
      );
    }
  }

  @override
  Future<void> close() async {
    await _sharesSubscription?.cancel();
    return super.close();
  }
}