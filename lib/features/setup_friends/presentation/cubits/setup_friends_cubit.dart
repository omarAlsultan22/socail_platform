import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/useCases/setup_friends_useCase.dart';
import 'package:social_app/core/data/models/message_result.dart';
import '../../../../core/presentation/states/app_sub_states.dart';
import '../../../../core/presentation/mixins/error_handler_mixin.dart';
import 'package:social_app/features/setup_friends/presentation/states/setup_friends_state.dart';


class SetupFriendsCubit extends Cubit<SetupFriendsState> with ErrorHandlerMixin<SetupFriendsState> {
  final SetupFriendsUseCase _useCases;

  SetupFriendsCubit({required SetupFriendsUseCase useCase})
      : _useCases = useCase,
        super(SetupFriendsState.initial());

  static SetupFriendsCubit get(context) => BlocProvider.of(context);

  void addFriend(int friendsNumber) {
    emit(state.copyWith(friendsNumber: friendsNumber,
        messageResult: MessageResult.success(message: 'Successfully added')));
  }

  Future<void> getSuggestsFriends() async {
    emit(state.copyWith(subState: LoadingState()));

    try {
      final usersList = await _useCases.executeGetSuggestsUsers();

      emit(state.copyWith(subState: SuccessState(), friendsList: usersList));
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
    required String uId
  }) async {
    emit(state.copyWith(messageResult: MessageResult.loading()));

    try {
      await _useCases.executeConfirmNewFriend(friendId: uId);

      emit(state.copyWith(messageResult: MessageResult.success(
          message: 'Successfully confirmed')));
    } catch (e, stackTrace) {
      handleError(e, stackTrace,
          onError: (failure) =>
              state.copyWith(
                  messageResult: MessageResult.error(error: failure)
              )
      );
    }
  }
}