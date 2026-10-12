import 'package:social_app/core/data/models/user_account.dart';


abstract class UserAccountRepository {

  Future<UserAccount> getAccount(String uId);

  Future<void> updateAccount({
    required UserAccount userAccount,
  });
}