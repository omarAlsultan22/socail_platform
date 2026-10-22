import '../../../../core/data/models/user_account.dart';
import '../../domain/repositories/sign_up_repository.dart';
import '../../../../core/domain/data_sources/remote/firestore/firestore_service.dart';


class SignUpRepositoryImpl implements SignUpRepository {
  final FirestoreService _dataSource;

  SignUpRepositoryImpl({
    required FirestoreService dataSource
  }) : _dataSource = dataSource;

  @override
  Future<void> createUserInfo({
    required UserAccount userModel,
  }) async {
    try {
      await _dataSource.setSupDoc(
          isMerge: false,
          collectionPath: 'accounts',
          docId: userModel.userId,
          data: userModel.toJson());
    } catch (e) {
      rethrow;
    }
  }
}