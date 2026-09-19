import '../../../../core/data/models/account_model.dart';
import '../../domain/repositories/sign_up_repository.dart';
import 'package:social_app/core/data/data_sources/remote/firestore/firestore_base_service.dart';


class FirebaseSignUpRepository implements SignUpRepository {
  final FirestoreBaseService _repository;

  FirebaseSignUpRepository({
    required FirestoreBaseService repository
  }) : _repository = repository;

  @override
  Future<void> createUserInfo({
    required UserAccount userModel,
  }) async {
    try {
      await _repository.setSupDoc(
          isMerge: false,
          collectionPath: 'accounts',
          docId: userModel.userId,
          data: userModel.toJson());
    } catch (e) {
      rethrow;
    }
  }
}