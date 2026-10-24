import '../../../../core/data/models/user_account.dart';
import '../../domain/repositories/sign_up_repository.dart';
import 'package:social_app/core/constants/app_strings.dart';
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
      await _dataSource.setSupDoc(
          isMerge: false,
          docId: userModel.userId,
          data: userModel.toJson(),
          collectionPath: AppStrings.accounts
      );
  }
}