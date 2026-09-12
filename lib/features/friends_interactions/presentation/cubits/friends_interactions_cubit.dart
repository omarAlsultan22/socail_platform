import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_app/core/data/models/message_result.dart';
import '../states/friends_interactions_state.dart';
import 'package:social_app/core/data/models/user_model.dart';
import '../../domain/useCases/friends_interactions_useCase.dart';
import '../../../../core/presentation/states/app_sub_states.dart';
import 'package:social_app/core/services/user_account_service.dart';
import '../../../../core/presentation/mixins/error_handler_mixin.dart';
import 'package:social_app/features/main/presentation/cubits/main_cubit.dart';


class FriendsInteractionsCubit extends Cubit<FriendsInteractionsState> with ErrorHandlerMixin<FriendsInteractionsState> {
  final FriendsInteractionsUseCase _useCase;
  final UserAccountService _userAccountService;

  FriendsInteractionsCubit({
    required FriendsInteractionsUseCase useCase,
    required UserAccountService userAccountService
  })
      : _useCase = useCase,
        _userAccountService = userAccountService,
        super(FriendsInteractionsState.initial());

  static FriendsInteractionsCubit get(context) => BlocProvider.of(context);

  StreamSubscription? _conversationsSubscription;


  Future<void> addFriendRequest() async {
    emit(state.copyWith(messageResult: MessageResult.loading()));

    try {
      final deletedUserId = await _useCase.executeAddFriendRequest();

      final newSuggestsList = state.friendsSuggestsList
          .where((item) => item.userId != deletedUserId)
          .toList();

      emit(
          state.copyWith(
              friendsSuggestsList: newSuggestsList,
              messageResult: MessageResult.success(
                  message: 'The request has been sent successfully')
          )
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

  Future<void> confirmNewFriend({
    required BuildContext context
  }) async {
    emit(state.copyWith(messageResult: MessageResult.loading()));

    try {
      final confirmedUserId = await _useCase.executeConfirmNewFriend();

      state.confirmFriend(confirmedUserId);
      await _executeDeclineAfterConfirm(context, confirmedUserId);
      emit(state.copyWith(messageResult: MessageResult.success(message: 'Your friend request has been approved')));
    } catch (e, stackTrace) {
      handleError(e, stackTrace,
          onError: (failure) =>
              state.copyWith(
                  messageResult: MessageResult.error(error: failure)
              )
      );
    }
  }

  // ✅ دالة مساعدة للتعامل مع decline بعد confirm
  Future<void> _executeDeclineAfterConfirm(BuildContext context, String userId) async {
    try {
      await _useCase.executeDeclineFriendRequestAfterConfirm(
        friendId: userId,
      );
      MainCubit.get(context).deleteRequest();
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
          _useCase.executeGetConversationsStream(
            getUserModelData: (id) => _userAccountService.getUserModelData(id: id),
          ).listen((groupedConversations) async {
            if(groupedConversations.isEmpty && state.)
            emit(state.updateFriendsRequestsList(groupedConversations));
          });
    } catch (e, stackTrace) {
      handleError(e, stackTrace,
          onError: (failure) =>
              state.copyWith(
                  subState: ErrorState(failure: failure)
              )
      );
    }
  }

  Stream<List<UserModel>> getConversationsStream({
    required String userId
  }) {
    return _useCase.executeGetConversationsStream(
      getUserModelData: (id) => _userAccountService.getUserModelData(id: id),
    );
  }

  Future<void> declineFriendRequest({
    required BuildContext context
  }) async {
    emit(state.copyWith(messageResult: MessageResult.loading()));

    try {
      final deletedUserId = await _useCase.executeDeclineFriendRequest();

      emit(state.declineFriendRequest(deletedUserId));/
      state.copyWith(messageResult: MessageResult.success(message: 'Deleted Successfully'));

      MainCubit.get(context).deleteRequest();/

    } catch (e, stackTrace) {
      handleError(e, stackTrace,
          onError: (failure) =>
              state.copyWith(
                  messageResult: MessageResult.error(error: failure)
              )
      );
    }
  }

  Future<void> getFriendsSuggests() async {
    emit(state.copyWith(subState: LoadingState()));

    try {
      final suggestsList = await _useCase.executeGetFriendsSuggests();
      emit(state.updateFriendsSuggestsList(suggestsList));

    } catch (e, stackTrace) {
      handleError(e, stackTrace,
          onError: (failure) =>
              state.copyWith(
                  subState: ErrorState(failure: failure)
              )
      );
    }
  }

  Future<void> updateFriendRequestsCount(String docId) async {
    try {
      await _useCase.executeUpdateFriendRequestsCount(docId: docId);
    } catch (e, stackTrace) {
      handleError(e, stackTrace,
          onError: (failure) =>
              state.copyWith(
                  subState: ErrorState(failure: failure)
              )
      );
    }
  }

  void deleteFriendSuggest({required int index}) {
    emit(state.deleteFriendSuggest(index));/
    state.copyWith(messageResult: MessageResult.success(message: 'Deleted Successfully'));
  }

  @override
  Future<void> close() {
    _conversationsSubscription?.cancel();
    return super.close();
  }
}