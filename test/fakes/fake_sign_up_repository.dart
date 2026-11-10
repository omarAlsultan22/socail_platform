import 'package:social_app/core/data/models/user_account.dart';
import 'package:social_app/features/auth/domain/repositories/sign_up_repository.dart';


class FakeSignUpRepository implements SignUpRepository {
  int createUserInfoCallCount = 0;
  UserAccount? lastUserModel;
  Object? createUserInfoError;

  @override
  Future<void> createUserInfo({required UserAccount userModel}) async {
    createUserInfoCallCount++;
    lastUserModel = userModel;
    if (createUserInfoError != null) throw createUserInfoError!;
  }
}