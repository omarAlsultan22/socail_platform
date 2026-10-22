import '../repositories/auth_repository.dart';
import '../repositories/sign_up_repository.dart';
import 'package:social_app/core/data/models/user_account.dart';


class SignUpUseCase {
  final AuthRepository _authRepository;
  final SignUpRepository _signUpRepository;

  SignUpUseCase({
    required AuthRepository authRepository,
    required SignUpRepository signUpRepository
  })
      :
        _authRepository = authRepository,
        _signUpRepository = signUpRepository;

  Future<void> signUpExecute({
    required String firstName,
    required String lastName,
    required String userEmail,
    required String userPassword,
  }) async {
    final userCredential = await _authRepository.signUp(
      userEmail: userEmail,
      userPassword: userPassword,
    );

    final user = userCredential.user;
    if (user != null && user.email != null && !user.isAnonymous) {
      UserAccount userAccount = UserAccount(
          userId: user.uid,
          firstName: firstName,
          lastName: lastName,
          fullName: '$firstName''$lastName'.trim()
      );
      await _signUpRepository.createUserInfo(
          userModel: userAccount
      );
    }
  }
}

