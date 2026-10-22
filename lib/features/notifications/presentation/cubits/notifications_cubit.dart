import 'dart:async';
import '../states/notifications_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/use_cases/notifications_use_case.dart';
import '../../../../core/presentation/mixins/error_handler_mixin.dart';
import 'package:social_app/core/presentation/states/app_sub_states.dart';


class NotificationsCubit extends Cubit<NotificationsState> with ErrorHandlerMixin<NotificationsState> {
  final NotificationsUseCase _useCases;

  StreamSubscription? _notificationsSubscription;

  NotificationsCubit({
    required NotificationsUseCase useCase
  })
      : _useCases = useCase,
        super(NotificationsState.initial());

  static NotificationsCubit get(context) => BlocProvider.of(context);

  void getNotifications() {
    emit(state.copyWith(subState: LoadingState()));

    try {
      _notificationsSubscription?.cancel();
      _notificationsSubscription =
          _useCases.executeGetNotificationsStream().listen(
                (notifications) {
                  if(notifications.isEmpty && state.notificationsListIsEmpty){
                    emit(state.copyWith(subState: InitialState()));
                    return;
                  }
                  emit(state.copyWith(
                    subState: SuccessState(),
                    notificationsList: notifications)
                  );
                },
            onError: (error) {
              handleError(error, StackTrace.current,
                  onError: (failure) =>
                      state.copyWith(
                          subState: ErrorState(failure: failure)
                      )
              );
            },
          );
    } catch (e, stackTrace) {
      handleError(e, stackTrace,
          onError: (failure) =>
              state.copyWith(
                  subState: ErrorState(failure: failure)
              )
      );
    }
  }

  @override
  Future<void> close() {
    _notificationsSubscription?.cancel();
    return super.close();
  }
}