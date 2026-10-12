import 'dart:async';
import '../states/likes_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/use_cases/get_likes_stream_use_case.dart';
import 'package:social_app/core/presentation/states/app_sub_states.dart';
import '../../../../../core/presentation/mixins/error_handler_mixin.dart';


class LikesCubit extends Cubit<LikesState> with ErrorHandlerMixin<LikesState> {
  final GetLikesStreamUseCase getLikesStreamUseCase;

  LikesCubit({
    required this.getLikesStreamUseCase,
  }) : super(LikesState.initial());

  static LikesCubit get(context) => BlocProvider.of(context);

  StreamSubscription? _likesSubscription;

  void listenToLikes(String? docId) {
    _likesSubscription?.cancel();

    if (docId == null || docId.isEmpty) {
      emit(state.copyWith(subState: InitialState()));
      return;
    }

    emit(state.copyWith(subState: LoadingState()));

    try {
      _likesSubscription = getLikesStreamUseCase(docId).listen(
            (likesList) {
          emit(state.copyWith(
              likesList: likesList,
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
    await _likesSubscription?.cancel();
    return super.close();
  }
}