import 'dart:async';
import 'package:flutter/cupertino.dart';
import '../states/friendship_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/useCases/friendship_useCase.dart';
import 'package:social_app/core/data/models/user_model.dart';
import 'package:social_app/core/data/models/message_result.dart';
import '../../../../core/presentation/states/app_sub_states.dart';
import 'package:social_app/core/services/user_account_service.dart';
import '../../../../core/presentation/mixins/error_handler_mixin.dart';
import 'package:social_app/features/main/presentation/cubits/main_cubit.dart';


class FriendshipCubit extends Cubit<FriendshipState> with ErrorHandlerMixin<FriendshipState> {
  final MainCubit _mainCubit;
  final FriendshipUseCase _useCase;
  final UserAccountService _userAccountService;

  FriendshipCubit({
    required MainCubit mainCubit,
    required FriendshipUseCase useCase,
    required UserAccountService userAccountService
  })
      : _useCase = useCase,
        _mainCubit = mainCubit,
        _userAccountService = userAccountService,
        super(FriendshipState.initial());

  static FriendshipCubit get(context) => BlocProvider.of(context);

  StreamSubscription? _conversationsSubscription;

  String? _getFriendUserId(int index) {
    final userModel = state.getFriendRequestByIndex(index);
    final uId = state.getUid(userModel);
    return uId;
  }

  Future<void> addFriendSuggest({required int index}) async {
    emit(state.copyWith(messageResult: MessageResult.loading()));

    try {
      final userModel = state.getFriendSuggestByIndex(index);
      final uId = state.getUid(userModel);
      await _useCase.executeAddFriendRequest(uId: uId);
      emit(
          state.addFriendSuggest(index)
      );
    } catch (e, stackTrace) {
      handleError(e, stackTrace,
          onError: (failure) =>
              state.copyWith(
                  messageResult: MessageResult.error(error: failure)
              )
      );
    }
  }

  Future<void> confirmNewFriend({
    required int index,
    required BuildContext context
  }) async {
    emit(state.copyWith(messageResult: MessageResult.loading()));

    try {

      final uId = _getFriendUserId(index);
      final confirmedUserId = await _useCase.executeConfirmNewFriend(uId: uId);

      await _executeDeclineAfterConfirm(context, confirmedUserId);
      emit(state.confirmFriend(index));
    } catch (e, stackTrace) {
      handleError(e, stackTrace,
          onError: (failure) =>
              state.copyWith(
                  messageResult: MessageResult.error(error: failure)
              )
      );
    }
  }

  Future<void> _executeDeclineAfterConfirm(BuildContext context, String userId) async {
    try {
      await _useCase.executeConfirmNewFriend(
        uId: userId,
      );
      _mainCubit.deleteRequest();
    } catch (e) {
      print('Error in _executeDeclineAfterConfirm: $e');
    }
  }

  void getFriendsRequests() {
    emit(state.copyWith(subState: LoadingState()));

    try {
      _conversationsSubscription?.cancel();
      _conversationsSubscription =
          _useCase.executeGetConversationsStream(
            getUserModelData: (id) =>
                _userAccountService.getUserModelData(id: id),
          ).listen((groupedConversations) async {
            if (groupedConversations.isEmpty &&
                state.friendsRequestsListIsEmpty) {
              emit(state.copyWith(subState: InitialState()));
              return;
            }
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
    required int index,
    required BuildContext context
  }) async {
    emit(state.copyWith(messageResult: MessageResult.loading()));

    try {
      final userModel = state.getFriendRequestByIndex(index);
      final uId = state.getUid(userModel);
      await _useCase.executeDeclineFriendRequest(uId: uId);
      _mainCubit.deleteRequest();
      emit(state.declineFriendRequest(index));

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

  void deleteFriendSuggest({required int index}) {
    emit(state.deleteFriendSuggest(index));
  }

  @override
  Future<void> close() {
    _conversationsSubscription?.cancel();
    return super.close();
  }
}