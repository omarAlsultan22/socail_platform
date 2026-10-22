import '../states/auth_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/data/models/message_result.dart';
import '../../../../core/network/domain/i_connectivity_service.dart';
import '../../../../core/presentation/mixins/error_handler_mixin.dart';
import '../../domain/use_cases/change_email_and_password_use_case.dart';
import 'package:social_app/core/errors/exceptions/network_app_exception.dart';


class ChangeEmailAndPasswordCubit extends Cubit<AuthState> with ErrorHandlerMixin<AuthState> {
  final ChangeEmailAndPasswordUseCase _useCase;
  final IConnectivityService _connectivityService;

  ChangeEmailAndPasswordCubit({
    required ChangeEmailAndPasswordUseCase useCase,
    required IConnectivityService connectivityService
  })
      : _useCase = useCase,
        _connectivityService = connectivityService,
        super(AuthState.initial());

  static ChangeEmailAndPasswordCubit get(context) => BlocProvider.of(context);

  Future<void> changeEmailAndPassword({
    required String newEmail,
    required String currentPassword,
    required String newPassword,
  }) async {
    final isConnected = await _connectivityService.checkInternetConnection();
    if (!isConnected) {
      throw NetworkAppException();
    }
    emit(AuthState(messageResult: MessageResult.loading()));
    try {
      await _useCase.updateProfileExecute(
          newEmail: newEmail,
          newPassword: newPassword,
          currentPassword: currentPassword
      );
      emit(
          AuthState(messageResult: MessageResult.success()));
    } catch (e, stackTrace) {
      handleError(e, stackTrace,
          onError: (failure) =>
              AuthState(messageResult: MessageResult.error(failure: failure)
              )
      );
    }
  }
}
