import '../repositories/auth_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/data/models/user_model.dart';
import 'package:cash_money/core/constants/app_keys.dart';
import '../../../settings/domain/repositories/settings_repository.dart';
import '../../../../core/data/data_sources/local/shared_preferences.dart';


class AuthUseCase {
  final AuthRepository _authRepository;
  final SettingsRepository? _settingsRepository;

  AuthUseCase({
    required AuthRepository authRepository,
    SettingsRepository? settingsRepository
  })
      :
        _authRepository = authRepository,
        _settingsRepository = settingsRepository!;


  Future<void> signInExecute({
    required String userEmail,
    required String userPassword,
  }) async {
    try {
      final userCredential = await _authRepository.signIn(
          userEmail: userEmail,
          userPassword: userPassword
      );
      CacheHelper.putValue(key: AppKeys.uId, value: userCredential.user!.uid);
    } catch (e) {
      rethrow;
    }
  }


  Future<void> signUpExecute({
    required String userName,
    required String userEmail,
    required String userPassword,
    required String userPhone,
    required String userLocation,
  }) async {
    try {
      final userCredential = await _authRepository.signUp(
        email: userEmail,
        password: userPassword,
      );

      UserModel userModel = UserModel(
        userName: userName,
        userPhone: userPhone,
        userLocation: userLocation,
        isEmailVerified: false,
      );

      await _settingsRepository!.setInfo(
          userModel: userModel, userCredential: userCredential);

      await CacheHelper.putValue(key: 'userName', value: userName);
    } catch (e) {
      rethrow;
    }
  }


  Future<void> updateProfileExecute({
    required String newEmail,
    required String newPassword,
    required String currentPassword
  }) async {
    final user = await _authRepository.updateProfile(
        newEmail: newEmail,
        newPassword: newPassword,
        currentPassword: currentPassword
    );
    if (user != null) {
      AuthCredential credential = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );
      try {
        await user.reauthenticateWithCredential(credential);
        await user.verifyBeforeUpdateEmail(newEmail).then((_) {
          user.updatePassword(newPassword).then((_) {});
        });
      } catch (e) {
        rethrow;
      }
    }
  }


  Future<void> signOutExecute() async {
    try {
      await _authRepository.signOut();
    } catch (e) {
      rethrow;
    }
  }
}

