import '../states/menu_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/useCases/menu_useCase.dart';
import '../../../../shared/constants/state_keys.dart';
import '../../../../core/errors/mappers/error_handler.dart';
import 'package:social_app/core/data/models/message_result.dart';
import 'package:social_app/core/presentation/states/app_sub_states.dart';


class AppModelCubit extends Cubit<MenuState> with ErrorHandlerMixin<MenuState>{
  final MenuUseCases _useCases;

  AppModelCubit({required MenuUseCases useCases})
      : _useCases = useCases,
        super(MenuState.initial());

  static AppModelCubit get(context) => BlocProvider.of(context);

  Future<void> getAccount(String uId) async {
    emit(state.setLoading(stateKey: StateKeys.getAccount));

    try {
      final userAccount = await _useCases.executeGetAccount(uId);

      emit(state.copyWith(subState: SuccessState(), firstModel: userAccount));
    } catch (e) {
      final errorHandler = ErrorHandler(
        error: e,
        stackTrace: StackTrace.current,
      );
      final exception = errorHandler.handleException();
      emit(state.setError(
        exception.toString(),
      ));
      print('Error fetching document: $e');
    }
  }

  Future<void> updateAccount({
    required String firstName,
    required String lastName,
    required String phone,
  }) async {
    emit(state.setLoading(stateKey: StateKeys.updateAccount));

    try {
      await _useCases.executeUpdateAccount(
        firstName: firstName,
        lastName: lastName,
        phone: phone,
      );

      if (state.account != null) {
        final updatedAccount = state.account!.copyWith(
          firstName: firstName,
          lastName: lastName,
          fullName: '$firstName $lastName',
          userPhone: phone,
        );
        emit(state.updateAccountData(updatedAccount));
      }

      emit(state.updateAccountSuccess());
    } catch (e) {
      final errorHandler = ErrorHandler(
        error: e,
        stackTrace: StackTrace.current,
      );
      final exception = errorHandler.handleException();
      emit(state.setError(
        exception.toString(),
        stateKey: StateKeys.updateAccount,
      ));
    }
  }

  Future<void> getInfo(String uId) async {
    emit(state.copyWith(subState: LoadingState()));
    try {
      final infoModel = await _useCases.executeGetInfo(uId);

      emit(state.copyWith(subState: SuccessState(), secondModel: infoModel));
    } catch (e) {
      final errorHandler = ErrorHandler(
        error: e,
        stackTrace: StackTrace.current,
      );
      final exception = errorHandler.handleException();
      emit(state.copyWith(subState: ErrorState(failure: exception),
      ));
    }
  }

  Future<void> updateProfileInfo({
    required final String userState,
    required final String userWork,
    required final String userLive,
    required final String userFrom,
    required final String userRelational,
  }) async {
    emit(state.copyWith(thirdModel: MessageResult.loading()));
    try {
      await updateProfileInfo(
          userState: userState,
          userWork: userWork,
          userLive: userLive,
          userFrom: userFrom,
          userRelational: userRelational
      );
      emit(state.copyWith(thirdModel: MessageResult.success()));
    } catch (e) {
      final errorHandler = ErrorHandler(
        error: e,
        stackTrace: StackTrace.current,
      );
      final exception = errorHandler.handleException();
      emit(state.copyWith(thirdModel: MessageResult.error(error: exception)));
    }
  }
}