import '../../../../core/data/models/post_model.dart';
import '../../../../core/data/models/comment_model.dart';
import '../../data/models/notification_model.dart';
import '../../../../core/presentation/states/app_sub_states.dart';
import '../../../../core/errors/exceptions/base/app_exception.dart';
import 'package:social_app/core/presentation/states/app_sup_states.dart';
import '../../../../core/presentation/states/base/main_loaded_state.dart';
import '../../../../core/presentation/states/base/main_app_sub_state.dart';


class NotificationsState extends TripleModelAppState<PostModel, List<CommentModel>, List<NotificationsModel>> {
  NotificationsState({
    super.firstModel,
    super.secondModel,
    super.thirdModel,
    required super.subState
  });

  factory NotificationsState.initial() {
    return NotificationsState(
      firstModel: null,
      secondModel: const [],
      thirdModel: const [],
      subState: InitialState(),
    );
  }

  @override
  NotificationsState copyWith({
    PostModel? firstModel,
    List<CommentModel>? secondModel,
    List<NotificationsModel>? thirdModel,
    MainAppSubState? subState,
  }) {
    return NotificationsState(
      subState: subState ?? this.subState,
      firstModel: firstModel ?? this.firstModel,
      secondModel: secondModel ?? this.secondModel,
    );
  }

  @override
  R when<R>({
    required R Function() onInitial,
    required R Function() onLoading,
    required R Function(LoadedState) onLoaded,
    required R Function(AppException) onError
  }) {
    return subState.when(
        onInitial: onInitial,
        onLoading: onLoading,
        onLoaded: () => onLoaded.call(dataModels),
        onError: (failure) => onError.call(failure)
    );
  }
}