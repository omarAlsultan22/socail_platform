import '../../../../core/errors/error_handler.dart';
import '../../../../core/errors/exceptions/app_exception.dart';
import 'package:cash_money/core/data/models/message_result_model.dart';
import 'package:cash_money/features/auth/domain/useCases/auth_useCase.dart';


class AuthServices {
  final AuthUseCase _authUseCase;

  AuthServices({required AuthUseCase authUseCase})
      : _authUseCase = authUseCase;

  Future<MessageResultModel> signIn({
    required String userEmail,
    required String userPassword,
  }) async {
    try {
      if (userEmail.isEmpty || userPassword.isEmpty) {
        throw('Fields cannot be empty.');
      }
      _authUseCase.signInExecute(
          userEmail: userEmail,
          userPassword: userPassword
      );
      return MessageResultModel(isSuccess: true);
    } on AppException catch (e) {
      final exception = ErrorHandler.handleException(e);
      return MessageResultModel(isSuccess: false, error: exception.message);
    }
  }


  Future<MessageResultModel> signUp({
    required String userName,
    required String userEmail,
    required String userPassword,
    required String userPhone,
    required String userLocation,
  }) async {
    try {
      await _authUseCase.signUpExecute(
          userName: userName,
          userEmail: userEmail,
          userPassword: userPassword,
          userPhone: userPhone,
          userLocation: userLocation
      );
      return MessageResultModel(isSuccess: true);
    } on AppException catch (e) {
      final exception = ErrorHandler.handleException(e);
      return MessageResultModel(isSuccess: false, error: exception.message);
    }
  }


  Future<MessageResultModel> changeEmailAndPassword({
    required String newEmail,
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      _authUseCase.updateProfileExecute(
          newEmail: newEmail,
          newPassword: newPassword,
          currentPassword: currentPassword
      );
      return MessageResultModel(isSuccess: true);
    } on AppException catch (e) {
      final exception = ErrorHandler.handleException(e);
      return MessageResultModel(isSuccess: false, error: exception.message);
    }
  }
}