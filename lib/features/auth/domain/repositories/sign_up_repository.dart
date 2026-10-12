import 'package:social_app/core/data/models/user_account.dart';


abstract class SignUpRepository {
  Future<void> createUserInfo({
    required UserAccount userModel
  });
}