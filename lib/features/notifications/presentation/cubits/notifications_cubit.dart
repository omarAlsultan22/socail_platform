import 'dart:async';
import 'package:flutter/cupertino.dart';
import '../states/notifications_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/user_details.dart';
import '../../domain/useCases/notifications_useCase.dart';
import '../../../../core/errors/mappers/error_handler.dart';
import '../../../../shared/componentes/public_components.dart';
import '../../../../core/presentation/mixins/error_handler_mixin.dart';


class NotificationsCubit extends Cubit<NotificationsState> with ErrorHandlerMixin<NotificationsState> {
  final NotificationsUseCases _useCases;

  StreamSubscription? _notificationsSubscription;

  NotificationsCubit({required NotificationsUseCases useCases})
      : _useCases = useCases,
        super(NotificationsState.initial());

  static NotificationsCubit get(context) => BlocProvider.of(context);

  Future<void> insertNotificationsRequests({
    required final String userUid,
    required final String userImage,
    required final String userName,
    required final String userAction,
  }) async {
    emit(state.setLoading());

    try {
      await _useCases.executeInsertNotification(
        userUid: userUid,
        userImage: userImage,
        userName: userName,
        userAction: userAction,
      );

      emit(state.insertNotificationSuccess());

    } catch (e) {
      final errorHandler = ErrorHandler(
        error: e,
        stackTrace: StackTrace.current,
      );
      final exception = errorHandler.handleException();
      emit(state.setError(exception.toString()));
    }
  }

  void getNotificationsRequests({required String userId}) {
    emit(state.setLoading(stateKey: StateKeys.getNotificationsRequests));

    try {
      _notificationsSubscription?.cancel();
      _notificationsSubscription =
          _useCases.executeGetNotificationsStream(userId: userId).listen(
                (notifications) {
              emit(state.getNotificationsSuccess(notifications));
            },
            onError: (error) {
              emit(state.setError(
                error.toString(),
                stateKey: StateKeys.getNotificationsRequests,
              ));
            },
          );
    } catch (e) {
      final errorHandler = ErrorHandler(
        error: e,
        stackTrace: StackTrace.current,
      );
      final exception = errorHandler.handleException();
      emit(state.setError(
        exception.toString(),
        stateKey: StateKeys.getNotificationsRequests,
      ));
    }
  }

  Future<void> getPostData({
    required String userId,
    required String postId,
  }) async {
    emit(state.setLoading(stateKey: StateKeys.getPostData));

    try {
      final result = await _useCases.executeGetPostData(
        userId: userId,
        postId: postId,
      );

      emit(state.getPostDataSuccess(
        post: result.post,
        comments: result.comments,
      ));

    } catch (e) {
      final errorHandler = ErrorHandler(
        error: e,
        stackTrace: StackTrace.current,
      );
      final exception = errorHandler.handleException();
      emit(state.setError(
        exception.toString(),
        stateKey: StateKeys.getPostData,
      ));
    }
  }

  Future<void> updateNotificationsCounter({
    required String docId,
    required BuildContext context,
  }) async {
    try {
      await _useCases.executeUpdateNotificationsCounter(docId: docId);

      MainLayoutCubit.get(context).deleteNotification();
      emit(state.updateNotificationsCounterSuccess());

    } catch (e) {
      final errorHandler = ErrorHandler(
        error: e,
        stackTrace: StackTrace.current,
      );
      final exception = errorHandler.handleException();
      emit(state.setError(
        exception.toString(),
        stateKey: StateKeys.updateNotificationsCounter,
      ));
    }
  }

  @override
  Future<void> close() {
    _notificationsSubscription?.cancel();
    return super.close();
  }
}