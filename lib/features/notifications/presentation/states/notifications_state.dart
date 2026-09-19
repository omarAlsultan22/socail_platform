import '../../data/models/notification_model.dart';
import '../../../../core/data/models/message_result.dart';
import '../../../../core/presentation/states/app_sub_states.dart';
import '../../../../core/errors/exceptions/base/app_exception.dart';
import '../../../../core/presentation/states/base/main_app_sub_state.dart';
import 'package:social_app/core/presentation/states/base/main_app_sup_state.dart';
import 'package:social_app/features/notifications/data/models/notifications_success_state.dart';


class NotificationsState extends MainAppSupState {
  final MessageResult messageResult;
  final List<NotificationsModel> notificationsList;

  const NotificationsState({
    required super.subState,
    required this.messageResult,
    required this.notificationsList
  });

  factory NotificationsState.initial() {
    return NotificationsState(
        subState: InitialState(),
        notificationsList: const [],
        messageResult: MessageResult.initial()
    );
  }

  NotificationsState copyWith({
    MainAppSubState? subState,
    MessageResult? messageResult,
    List<NotificationsModel>? notificationsList,
  }) {
    return NotificationsState(
        subState: subState ?? this.subState,
        messageResult: messageResult ?? this.messageResult,
        notificationsList: notificationsList ?? this.notificationsList
    );
  }

  @override
  NotificationsSuccessState get dataModels =>
      NotificationsSuccessState(
          messageResult: messageResult,
          notificationsList: notificationsList,
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