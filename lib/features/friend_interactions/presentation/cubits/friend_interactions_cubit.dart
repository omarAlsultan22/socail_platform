import 'dart:async';
import '../../../main/cubit.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../states/friend_interactions_state.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/errors/mappers/error_handler.dart';
import 'package:social_app/core/data/models/user_model.dart';
import '../../../../shared/componentes/public_components.dart';
import '../../domain/useCases/friend_interactions_useCase.dart';
import '../../../../core/presentation/states/app_sub_states.dart';
import '../../../../core/presentation/mixins/error_handler_mixin.dart';


class FriendInteractionsCubit extends Cubit<FriendInteractionsState> with ErrorHandlerMixin<FriendInteractionsState> {
  final FriendInteractionsUseCase _useCases;
  FriendInteractionsCubit({required FriendInteractionsUseCase useCases})
      : _useCases = useCases,
        super(FriendInteractionsState.initial());

  static FriendInteractionsCubit get(context) => BlocProvider.of(context);

  StreamSubscription? _conversationsSubscription;


  Future<void> addFriendRequest({
    required final int index,
  }) async {
    // 1. حالة تحميل
    emit(state.copyWith(subState: LoadingState()));

    try {
      // 2. استدعاء الـ UseCase
      final deletedUserId = await _useCases.executeAddFriendRequest(
        index: index,
        friendsSuggestsList: state.friendsSuggestsList,
      );

      // 3. تعديل القائمة وإصدار الحالة الجديدة
      final newSuggestsList = state.friendsSuggestsList
          .where((item) => item.userId != deletedUserId)
          .toList();

      emit(state.updateFriendsSuggestsList(newSuggestsList));

    } catch (e) {
      // 4. معالجة الخطأ
      final errorHandler = ErrorHandler(
          error: e,
          stackTrace: StackTrace.current
      );
      final exception = errorHandler.handleException();
      emit(state.copyWith(subState: ErrorState(failure: exception)));
    }
  }

  Future<void> confirmNewFriend({
    required int index,
    required BuildContext context
  }) async {
    emit(state.copyWith(subState: LoadingState()));

    try {
      final confirmedUserId = await _useCases.executeConfirmNewFriend(
        userId: state.friendsRequestsList;
      );

      emit(state.confirmFriend(confirmedUserId));

      await _executeDeclineAfterConfirm(context, confirmedUserId);

    } catch (e) {
      final errorHandler = ErrorHandler(
          error: e,
          stackTrace: StackTrace.current
      );
      final exception = errorHandler.handleException();
      emit(state.copyWith(subState: ErrorState(failure: exception)));
    }
  }

  // ✅ دالة مساعدة للتعامل مع decline بعد confirm
  Future<void> _executeDeclineAfterConfirm(BuildContext context, String userId) async {
    try {
      await _useCases.executeDeclineFriendRequestAfterConfirm(
        friendId: userId,
      );
      MainLayoutCubit.get(context).deleteRequest();
    } catch (e) {
      // لا نريد إعادة الخطأ لأن العملية الأساسية نجحت
      print('Error in _executeDeclineAfterConfirm: $e');
    }
  }

  void getFriendsRequests() {
    emit(state.copyWith(subState: LoadingState()));

    try {
      _conversationsSubscription?.cancel();
      _conversationsSubscription =
          _useCases.executeGetConversationsStream(
            userId: UserDetails.uId,
            getUserModelData: (id) => getUserModelData(id: id),
          ).listen((groupedConversations) async {
            // تحديث القائمة من الـ Stream
            emit(state.updateFriendsRequestsList(groupedConversations));
          });
    } catch (e, stackTrace) {
      final errorHandler = ErrorHandler(
          error: e,
          stackTrace: stackTrace
      );
      final exception = errorHandler.handleException();
      emit(state.copyWith(subState: ErrorState(failure: exception)));
    }
  }

  Stream<List<UserModel>> getConversationsStream({
    required String userId
  }) {
    return _useCases.executeGetConversationsStream(
      userId: userId,
      getUserModelData: (id) => getUserModelData(id: id),
    );
  }

  Future<void> declineFriendRequest({
    required int index,
    required BuildContext context
  }) async {
    emit(state.copyWith(subState: LoadingState()));

    try {
      // 1. استدعاء الـ UseCase
      final deletedUserId = await _useCases.executeDeclineFriendRequest(
        index: index,
        friendsRequestsList: state.friendsRequestsList,
      );

      // 2. تعديل القائمة وإصدار الحالة الجديدة
      emit(state.declineFriendRequest(deletedUserId));

      // 3. تحديث الـ MainLayout
      MainLayoutCubit.get(context).deleteRequest();

    } catch (e) {
      final errorHandler = ErrorHandler(
          error: e,
          stackTrace: StackTrace.current
      );
      final exception = errorHandler.handleException();
      emit(state.copyWith(subState: ErrorState(failure: exception)));
    }
  }

  Future<void> getFriendsSuggests() async {
    emit(state.copyWith(subState: LoadingState()));

    try {
      final suggestsList = await _useCases.executeGetFriendsSuggests();
      emit(state.updateFriendsSuggestsList(suggestsList));

    } catch (e, stackTrace) {
      final errorHandler = ErrorHandler(
          error: e,
          stackTrace: stackTrace
      );
      final exception = errorHandler.handleException();
      emit(state.copyWith(subState: ErrorState(failure: exception)));
    }
  }

  Future<void> updateFriendRequestsCount(String docId) async {
    try {
      await _useCases.executeUpdateFriendRequestsCount(docId: docId);
    } catch (e) {
      final errorHandler = ErrorHandler(
          error: e,
          stackTrace: StackTrace.current
      );
      final exception = errorHandler.handleException();
      emit(state.copyWith(subState: ErrorState(failure: exception)));
    }
  }

  void deleteFriendSuggest({required int index}) {
    emit(state.deleteFriendSuggest(index));
  }

  @override
  Future<void> close() {
    _conversationsSubscription?.cancel();
    return super.close();
  }
}