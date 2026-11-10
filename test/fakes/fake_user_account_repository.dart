import 'package:social_app/core/data/models/user_account.dart';
import 'package:social_app/features/user_account/domain/repositories/user_account_repository.dart';


class FakeUserAccountRepository implements UserAccountRepository {
  // ===== getAccount =====
  UserAccount getAccountResult = UserAccount(
    userId: 'uid-1',
    firstName: 'Ali',
    lastName: 'Ahmed',
    fullName: 'Ali Ahmed',
  );
  Object? getAccountError;
  int getAccountCallCount = 0;
  String? lastGetAccountUid;

  @override
  Future<UserAccount> getAccount(String uId) async {
    getAccountCallCount++;
    lastGetAccountUid = uId;
    if (getAccountError != null) throw getAccountError!;
    return getAccountResult;
  }

  // ===== updateAccount =====
  int updateAccountCallCount = 0;
  UserAccount? lastUpdateUserAccount;
  Object? updateAccountError;

  @override
  Future<void> updateAccount({required UserAccount userAccount}) async {
    updateAccountCallCount++;
    lastUpdateUserAccount = userAccount;
    if (updateAccountError != null) throw updateAccountError!;
  }
}