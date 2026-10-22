import '../../../../core/domain/data_sources/remote/auth_service.dart';
import '../../domain/repositories/auth_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';


class AuthRepositoryImpl implements AuthRepository {
  final AuthService _service;

  AuthRepositoryImpl({required AuthService service})
      : _service = service;

  @override
  Future<UserCredential> signIn({
    required String userEmail,
    required String userPassword
  }) async {
    return await _service.signIn(
      email: userEmail,
      password: userPassword,
    ).then((value) {
      return value;
    });
  }

  @override
  Future<UserCredential> signUp({
    required String userEmail,
    required String userPassword
  }) async {
    return await _service
        .signUp(
        email: userEmail,
        password: userPassword
    ).then((value) {
      return value;
    });
  }

  @override
  Future<User?> updateProfile({
    required String newEmail,
    required String currentPassword,
    required String newPassword
  }) async {
    final user = await _service.updateProfile(
        newEmail: newEmail,
        currentPassword: currentPassword,
        newPassword: newPassword);
    return user;
  }

  @override
  Future<void> sendResetEmail({required String userEmail}) async {
    await _service.sendResetEmail(userEmail: userEmail);
  }
}