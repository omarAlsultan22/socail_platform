import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/repositories/auth_repository.dart';


class FirebaseAuthRepository implements AuthRepository {
  final FirebaseAuth _auth;

  FirebaseAuthRepository({required FirebaseAuth auth}) : _auth = auth;

  @override
  Future<UserCredential> signIn({
    required String userEmail,
    required String userPassword
  }) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: userEmail,
        password: userPassword,
      ).then((value) {
        return value;
      });
    }
    catch (e) {
      rethrow;
    }
  }


  @override
  Future<UserCredential> signUp({
    required String email,
    required String password
  }) async {
    try {
      return await _auth
          .createUserWithEmailAndPassword(
          email: email,
          password: password
      ).then((value) {
        return value;
      });
    }
    catch (e) {
      rethrow;
    }
  }


  @override
  Future<User?> updateProfile({
    required String newEmail,
    required String currentPassword,
    required String newPassword
  }) async {
    try {
      final user = _auth.currentUser;
      return user;
    }
    catch (e) {
      rethrow;
    }
  }


  @override
  Future<void> signOut() async {
    _auth.signOut();
  }
}