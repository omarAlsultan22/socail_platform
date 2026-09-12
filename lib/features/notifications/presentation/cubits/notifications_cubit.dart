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
  final NotificationsUseCase _useCases;

  StreamSubscription? _notificationsSubscription;

  NotificationsCubit({required NotificationsUseCase useCase})
      : _useCases = useCase,
        super(NotificationsState.initial());

  static NotificationsCubit get(context) => BlocProvider.of(context);

  Future<void> insertNotifications({
    required final String userUid,
    required final String userImage,
    required final String userName,
    required final String userAction,
  }) async {
    emit(state.copyWith(messageResult: MessageResult.loading()));

    try {
      await _useCases.executeInsertNotification(
        userUid: userUid,
        userImage: userImage,
        fullName: userName,
        userAction: userAction,
      );

      emit(state.copyWith(messageResult: MessageResult.success()));/

    } catch (e, stackTrace) {
      handleError(e, stackTrace,
          onError: (failure) =>
              state.copyWith(
                  messageResult: MessageResult.error(error: failure)
              )
      );
    }
  }

  void getNotifications() {
    emit(state.copyWith(subState: LoadingState()));

    try {
      _notificationsSubscription?.cancel();
      _notificationsSubscription =
          _useCases.executeGetNotificationsStream().listen(
                (notifications) {
              emit(state.copyWith(subState: SuccessState()));
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

  Future<void> getPostData({
    required String userId,
    required String postId,
  }) async {
    emit(state.copyWith(subState: LoadingState()));

    try {
      final result = await _useCases.executeGetPostData(
        userId: userId,
        postId: postId,
      );

      emit(state.copyWith(
        postModel: result.post,
        commentsList: result.comments,
      ));

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
    MainCubit.get(context).deleteNotification();/
    emit(state.copyWith(subState: SuccessState()));
  }

  @override
  Future<void> close() {
    _notificationsSubscription?.cancel();
    return super.close();
  }
}