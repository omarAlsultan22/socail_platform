import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:social_app/core/constants/app_strings.dart';
import 'package:social_app/features/main/domain/data_sources/main_data_source.dart';
import '../../../../core/data/data_sources/remote/firestore/firestore_service_impl.dart';


class MainDataSourceImpl extends FirestoreServiceImpl implements MainDataSource{

  @override
  Future<QuerySnapshot<Map<String, dynamic>>> getAllUsersExceptCurrent({
    required String uId,
  }) async {
    return await firestore
        .collection(AppStrings.users)
        .where(AppStrings.userId, isNotEqualTo: uId)
        .get()
        .timeout(duration);
  }

  @override
  Future<QuerySnapshot<Map<String, dynamic>>> getUnreadNotifications() async {
    return await firestore
        .collection(AppStrings.notifications)
        .where(AppStrings.isRead, isEqualTo: false)
        .get()
        .timeout(duration);
  }

  @override
  Stream<QuerySnapshot<Map<String, dynamic>>> getNotificationsStream() {
    return firestore
        .collection(AppStrings.notifications)
        .where(AppStrings.isRead, isEqualTo: false)
        .snapshots()
        .timeout(duration);
  }
}