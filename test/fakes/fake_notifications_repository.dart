import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:social_app/features/notifications/data/models/notification_model.dart';
import 'package:social_app/features/notifications/domain/repositories/notifications_repository.dart';


class FakeNotificationsRepository implements NotificationsRepository {
  // ===== getNotificationsStream =====
  Stream<QuerySnapshot>? notificationsStream;
  int getNotificationsStreamCallCount = 0;
  String? lastNotificationsStreamUserId;

  @override
  Stream<QuerySnapshot> getNotificationsStream({required String userId}) {
    getNotificationsStreamCallCount++;
    lastNotificationsStreamUserId = userId;
    return notificationsStream!;
  }

  // ===== convertNotificationsToModels =====
  List<NotificationsModel> convertResult = [];
  Object? convertError;
  int convertCallCount = 0;

  @override
  Future<List<NotificationsModel>> convertNotificationsToModels({
    required QuerySnapshot notificationsSnapshot,
  }) async {
    convertCallCount++;
    if (convertError != null) throw convertError!;
    return convertResult;
  }

  // ===== updateNotificationReadStatus =====
  int updateCallCount = 0;
  String? lastUpdateDocId;
  Object? updateError;

  @override
  Future<void> updateNotificationReadStatus({required String docId}) async {
    updateCallCount++;
    lastUpdateDocId = docId;
    if (updateError != null) throw updateError!;
  }

  // باقي الدوال — noSuchMethod
  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError(
        'FakeNotificationsRepository.${invocation.memberName} not stubbed',
      );
}