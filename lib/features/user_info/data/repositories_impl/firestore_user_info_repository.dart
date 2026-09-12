import '../../domain/repositories/user_info_repository.dart';
import 'package:social_app/core/data/models/profile_info_model.dart';
import '../../../../core/data/data_sources/remote/firestore/firestore_base_service.dart';
import 'package:social_app/core/presentation/data/repositories_impl/firestore_base_repository.dart';


class FirestoreUserInfoRepository extends FirestoreBaseRepository implements UserInfoRepository {
  final FirestoreBaseService _repository;

  FirestoreUserInfoRepository({
    required FirestoreBaseService repository
  })
      : _repository = repository;

  @override
  Future<void> updateProfileInfo({
    required String docId,
    required ProfileInfoModel infoModel
  }) async {
    try {
      await _repository.setSupDoc(
        docId: docId,
        isMerge: true,
        collectionPath: 'info',
        data: infoModel.toJson(),
      );
    } catch (e) {
      rethrow;
    }
  }
}
