import '../../data/models/notification_model.dart';
import '../../../../core/data/models/post_model.dart';
import '../../../../core/data/models/comment_model.dart';
import '../../../../core/data/models/message_result.dart';
import '../../../../core/presentation/states/app_sub_states.dart';
import '../../../../core/errors/exceptions/base/app_exception.dart';
import '../../../../core/presentation/states/base/main_app_sub_state.dart';
import 'package:social_app/core/presentation/states/base/main_app_sup_state.dart';
import 'package:social_app/features/notifications/data/models/notifications_success_state.dart';


class NotificationsState extends MainAppSupState {
  final PostModel postModel;
  final MessageResult messageResult;
  final List<CommentModel> commentsList;
  final List<NotificationsModel> notificationsList;

  const NotificationsState({
    required super.subState,
    required this.postModel,
    required this.commentsList,
    required this.messageResult,
    required this.notificationsList
  });

  factory NotificationsState.initial() {
    return NotificationsState(
      postModel: PostModel(),
      commentsList: const [],
      subState: InitialState(),
      notificationsList: const [],
      messageResult: MessageResult.initial()
    );
  }

  NotificationsState copyWith({
    PostModel? postModel,
    MessageResult? messageResult,
    List<CommentModel>? commentsList,
    List<NotificationsModel>? notificationsList,
    MainAppSubState? subState,
  }) {
    return NotificationsState(
        subState: subState ?? this.subState,
        postModel: postModel ?? this.postModel,
        commentsList: commentsList ?? this.commentsList,
        messageResult: messageResult ?? this.messageResult,
        notificationsList: notificationsList ?? this.notificationsList
    );
  }

  @override
  NotificationsSuccessState get dataModels => NotificationsSuccessState(
      postModel: postModel,
      commentsList: commentsList,
      messageResult: messageResult,
      notificationsList: notificationsList
  );

  @override
  R when<R>({
    required R Function() onInitial,
    required R Function() onLoading,
    required R Function(NotificationsSuccessState) onLoaded,
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