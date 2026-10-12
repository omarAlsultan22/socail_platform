import '../../../../../core/data/models/my_model.dart';
import 'package:social_app/core/presentation/states/app_sub_states.dart';
import 'package:social_app/core/errors/exceptions/base/app_exception.dart';
import '../../../../../core/presentation/states/base/main_app_sub_state.dart';
import 'package:social_app/core/presentation/states/base/main_app_sup_state.dart';
import 'package:social_app/features/interactions/likes/data/models/likes_success_state.dart';


class LikesState extends MainAppSupState {
  final List<MyModel> likesList;

  LikesState({
    required super.subState,
    required this.likesList,
  });

  factory LikesState.initial(){
    return LikesState(
        likesList: [],
        subState: InitialState(),
    );
  }

  LikesState copyWith({
    MainAppSubState? subState,
    List<MyModel>? likesList
  }) {
    return LikesState(
        subState: subState ?? this.subState,
        likesList: likesList ?? this.likesList,
    );
  }

  @override
  CommentsLikesSuccessState get dataModels => CommentsLikesSuccessState(
      commentsLikesList: likesList,
  );

  @override
  R when<R>({
    required R Function() onInitial,
    required R Function() onLoading,
    required R Function(CommentsLikesSuccessState) onLoaded,
    required R Function(AppException) onError}) {
    return subState.when(
        onInitial: onInitial,
        onLoading: onLoading,
        onLoaded: () => onLoaded(dataModels),
        onError: (failure) => onError(failure)
    );
  }
}