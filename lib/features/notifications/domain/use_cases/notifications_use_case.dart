import '../repositories/notifications_repository.dart';
import 'package:social_app/core/services/session_service.dart';
import 'package:social_app/features/notifications/data/models/notification_model.dart';


class NotificationsUseCase {
  final SessionService _sessionService;
  final NotificationsRepository _repository;

  NotificationsUseCase({
    required SessionService sessionService,
    required NotificationsRepository repository
  })
      : _repository = repository,
        _sessionService = sessionService;

  Stream<List<NotificationsModel>> executeGetNotificationsStream() {
    return _repository.getNotificationsStream(userId: _sessionService.currentUid).asyncMap(
            (notificationsSnapshot) async {
          return await _repository.convertNotificationsToModels(
            notificationsSnapshot: notificationsSnapshot,
          );
        }
    );
  }

  Future<void> executeUpdateNotificationsCounter({
    required String docId,
  }) async {
    await _repository.updateNotificationReadStatus(docId: docId);
  }
}