import 'package:firebase_auth/firebase_auth.dart';
import '../repositories/auth_repository.dart';


class ChangeEmailAndPasswordUseCase {
  final AuthRepository _authRepository;

  ChangeEmailAndPasswordUseCase({
    required AuthRepository authRepository,
  })
      :
        _authRepository = authRepository;

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
    if (user == null) {
      throw Exception('No user is currently logged in');
    }

    final credential = EmailAuthProvider.credential(
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

