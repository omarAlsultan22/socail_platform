import '../states/auth_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/use_cases/sign_up_use_case.dart';
import '../../../../core/data/models/message_result.dart';
import '../../../../core/network/domain/i_connectivity_service.dart';
import '../../../../core/errors/exceptions/network_app_exception.dart';
import '../../../../core/presentation/mixins/error_handler_mixin.dart';


class SignUpCubit extends Cubit<AuthState> with ErrorHandlerMixin<AuthState> {
  final SignUpUseCase _useCase;
  final IConnectivityService _connectivityService;

  SignUpCubit({
    required SignUpUseCase useCase,
    required IConnectivityService connectivityService,

  })
      : _useCase = useCase,
        _connectivityService = connectivityService,
        super(AuthState.initial());

  static SignUpCubit get(context) => BlocProvider.of(context);

  Future<void> signUp({
    required String firstName,
    required String lastName,
    required String userEmail,
    required String userPassword,
  }) async {
    final isConnected = await _connectivityService.checkInternetConnection();
    if (!isConnected) {
      throw NetworkAppException();
    }
    emit(AuthState(messageResult: MessageResult.loading()));
    try {
      await _useCase.signUpExecute(
          firstName: firstName,
          lastName: lastName,
          userEmail: userEmail,
          userPassword: userPassword,
      );
      emit(AuthState(
          messageResult: MessageResult.success()));
    } catch (e, stackTrace) {
      handleError(e, stackTrace,
          onError: (failure) =>
              AuthState(messageResult: MessageResult.error(failure: failure)
              )
      );
    }
  }
}