import '../states/user_account_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/useCases/user_account_use_case.dart';
import 'package:social_app/core/data/models/message_result.dart';
import '../../../../core/presentation/mixins/error_handler_mixin.dart';
import 'package:social_app/core/presentation/states/app_sub_states.dart';


class UserAccountCubit extends Cubit<UserAccountState> with ErrorHandlerMixin<UserAccountState> {
  final UserAccountUseCase _useCases;

  UserAccountCubit({required UserAccountUseCase useCase})
      : _useCases = useCase,
        super(UserAccountState.initial());

  static UserAccountCubit get(context) => BlocProvider.of(context);

  Future<void> getAccount() async {
    emit(state.copyWith(subState: const LoadingState()));

    try {
      final userAccount = await _useCases.executeGetAccount();

      emit(state.copyWith(subState: SuccessState(), userAccount: userAccount));
    } catch (e, stackTrace) {
      handleError(e, stackTrace,
          onError: (failure) =>
              state.copyWith(
                  subState: ErrorState(failure: failure)
              )
      );
    }
  }

  Future<void> updateAccount({
    required String firstName,
    required String lastName,
  }) async {
    emit(state.copyWith(subState: const LoadingState()));

    try {
      await _useCases.executeUpdateAccount(
        firstName: firstName,
        lastName: lastName,
      );

      if (state.userAccount != null) {
        final updatedAccount = state.userAccountCopyWith(
          firstName: firstName,
          lastName: lastName,
          fullName: '$firstName $lastName',
        );
        emit(state.copyWith(userAccount: updatedAccount));
      }

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
}