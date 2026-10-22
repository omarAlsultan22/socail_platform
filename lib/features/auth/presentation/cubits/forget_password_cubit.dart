import '../states/auth_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../../../core/data/models/message_result.dart';
import '../../../../core/network/domain/i_connectivity_service.dart';
import '../../../../core/errors/exceptions/validation_exception.dart';
import '../../../../core/presentation/mixins/error_handler_mixin.dart';
import '../../../../core/errors/exceptions/network_app_exception.dart';


class ForgetPasswordCubit extends Cubit<AuthState> with ErrorHandlerMixin<AuthState> {
  final AuthRepository _repository;
  final IConnectivityService _connectivityService;

  ForgetPasswordCubit({
    required AuthRepository repository,
    required IConnectivityService connectivityService
  })
      : _repository = repository,
        _connectivityService = connectivityService,
        super(AuthState.initial());

  static ForgetPasswordCubit get(context) => BlocProvider.of(context);

  Future<void> sendResetEmail({
    required String userEmail
  }) async {
    final isConnected = await _connectivityService.checkInternetConnection();
    if (!isConnected) {
      throw NetworkAppException();
    }
    if (userEmail.isEmpty) {
      throw ValidationException();
    }
    emit(AuthState(messageResult: MessageResult.loading()));
    try {
      await _repository.sendResetEmail(
        userEmail: userEmail,
      );
      emit(AuthState(
          messageResult: MessageResult.success(
              message: 'The reset link has been sent to your email')));
    } catch (e, stackTrace) {
      handleError(e, stackTrace,
          onError: (failure) =>
              AuthState(messageResult: MessageResult.error(failure: failure)
              )
      );
    }
  }
}