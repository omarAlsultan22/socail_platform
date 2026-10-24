import 'package:social_app/core/constants/app_strings.dart';
import 'package:social_app/core/data/models/user_account.dart';
import '../../domain/repositories/user_account_repository.dart';
import 'package:social_app/core/errors/exceptions/validation_exception.dart';
import '../../../../core/domain/data_sources/remote/firestore/firestore_service.dart';


class UserAccountRepositoryImpl implements UserAccountRepository {
  final FirestoreService _dataSource;

  UserAccountRepositoryImpl({
    required FirestoreService dataSource
  })
      : _dataSource = dataSource;

  @override
  Future<UserAccount> getAccount(String uId) async {
    final docRef = _dataSource.getDocRef(
        docId: uId, collectionPath: AppStrings.accounts);
    final docSnapshot = await docRef.get();

    if (!docSnapshot.exists) {
      throw ValidationException(error: 'Account document does not exist');
    }

    final data = docSnapshot.data() as Map<String, dynamic>;
    return UserAccount.fromJson(data);
  }

  @override
  Future<void> updateAccount({
    required UserAccount userAccount,
  }) async {
    await _dataSource.updateDoc(
      docId: userAccount.userId,
      collectionPath: AppStrings.accounts,
      data: userAccount.toJson(),
    );
  }
}
