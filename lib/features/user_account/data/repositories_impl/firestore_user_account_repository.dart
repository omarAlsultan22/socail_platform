import '../../domain/repositories/user_account_repository.dart';
import 'package:social_app/core/data/models/account_model.dart';
import 'package:social_app/core/errors/exceptions/validation_exception.dart';
import '../../../../core/data/data_sources/remote/firestore/firestore_base_service.dart';


class FirestoreUserAccountRepository implements UserAccountRepository {
  final FirestoreBaseService _repository;

  FirestoreUserAccountRepository({
    required FirestoreBaseService repository
  })
      : _repository = repository;

  @override
  Future<UserAccount> getAccount(String uId) async {
    try {
      final docRef = _repository.docRef(docId: uId, collectionPath: 'accounts');
      final docSnapshot = await docRef.get();

      if (!docSnapshot.exists) {
        throw ValidationException(error: 'Account document does not exist');
      }

      final data = docSnapshot.data() as Map<String, dynamic>;
      return UserAccount.fromJson(data);
    }
    catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> updateAccount({
    required UserAccount userAccount,
  }) async {
    try {
      await _repository.updateDoc(
        docId: userAccount.userId,
        collectionPath: 'accounts',
        data: userAccount.toJson(),
      );
    }
    catch (e) {
      rethrow;
    }
  }
}
