import 'package:social_app/core/data/models/account_model.dart';


abstract class UserAccountRepository {

  Future<UserAccount> getAccount(String uId);

  Future<void> updateAccount({
    required UserAccount userAccount,
  });
}