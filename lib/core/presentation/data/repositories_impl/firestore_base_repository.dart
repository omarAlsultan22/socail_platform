import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:social_app/core/presentation/domain/repositories/base_repository.dart';


class FirestoreBaseRepository implements BaseRepository{

  @override
  Future<Map<String, dynamic>> getInfo({
    required String uid
  }) async {
    try {
      final firestore = FirebaseFirestore.instance
          .collection('info')
          .doc(uid);

      final getUserInfo = await firestore.get();

      if (getUserInfo.exists) {
        final userInfo = getUserInfo.data() as Map<String, dynamic>;

        return userInfo;
      }
      return {};
    }
    catch(e){
      rethrow;
    }
  }
}