import 'dart:async';
import 'package:flutter/cupertino.dart';
import '../states/notifications_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/useCases/notifications_useCase.dart';
import 'package:social_app/core/data/models/message_result.dart';
import '../../../../core/presentation/mixins/error_handler_mixin.dart';
import 'package:social_app/core/presentation/states/app_sub_states.dart';
import 'package:social_app/features/main/presentation/cubits/main_cubit.dart';


class NotificationsCubit extends Cubit<NotificationsState> with ErrorHandlerMixin<NotificationsState> {
  final MainCubit _mainCubit;
  final NotificationsUseCase _useCases;

  StreamSubscription? _notificationsSubscription;

  NotificationsCubit({
    required MainCubit mainCubit,
    required NotificationsUseCase useCase
  })
      : _useCases = useCase,
        _mainCubit = mainCubit,
        super(NotificationsState.initial());

  static NotificationsCubit get(context) => BlocProvider.of(context);

  void getNotifications() {
    emit(state.copyWith(subState: LoadingState()));

    try {
      _notificationsSubscription?.cancel();
      _notificationsSubscription =
          _useCases.executeGetNotificationsStream().listen(
                (notifications) {
                  if(notifications.isEmpty){
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

  Future<void> updateNotificationsCounter({
    required String docId,
    required BuildContext context,
  }) async {
    await _useCases.executeUpdateNotificationsCounter(docId: docId);
    _mainCubit.deleteNotification();
    emit(state.copyWith(subState: SuccessState()));
  }

  @override
  Future<void> close() {
    _notificationsSubscription?.cancel();
    return super.close();
  }
}