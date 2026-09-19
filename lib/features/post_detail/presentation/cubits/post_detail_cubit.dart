import 'dart:async';
import '../states/post_detail_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/useCases/post_detail_use_case.dart';
import 'package:social_app/core/data/models/message_result.dart';
import '../../../../core/presentation/mixins/error_handler_mixin.dart';
import 'package:social_app/core/presentation/states/app_sub_states.dart';
import 'package:social_app/core/errors/exceptions/validation_exception.dart';


class PostDetailCubit extends Cubit<PostDetailState> with ErrorHandlerMixin<PostDetailState> {
  final PostDetailUseCase _useCases;

  StreamSubscription? _notificationsSubscription;

  PostDetailCubit({
    required PostDetailUseCase useCase
  })
      : _useCases = useCase,
        super(PostDetailState.initial());

  static PostDetailCubit get(context) => BlocProvider.of(context);

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

      emit(state.copyWith(messageResult: MessageResult.success()));

    } catch (e, stackTrace) {
      handleError(e, stackTrace,
          onError: (failure) =>
              state.copyWith(
                  messageResult: MessageResult.error(error: failure)
              )
      );
    }
  }

  Future<void> getPostData({
    required String userId,
    required String postId,
  }) async {
    emit(state.copyWith(subState: LoadingState()));

    if (userId.isEmpty || postId.isEmpty) {
      throw ValidationException(
        error: 'userId and postId must not be empty',
      );
    }
    try {
      final postDetailModel = await _useCases.executeGetPostData(
        userId: userId,
        postId: postId,
      );

      if (postDetailModel.postModel != null &&
          postDetailModel.commentsList != null) {
        emit(
            state.copyWith(
                postModel: postDetailModel.postModel,
                commentsList: postDetailModel.commentsList,
                subState: SuccessState()
            )
        );
        return;
      }
      emit(state.copyWith(subState: InitialState()));
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