import 'package:mocktail/mocktail.dart';
import 'package:flutter_test/flutter_test.dart';
import '../../../../fakes/mock_session_service.dart';
import '../../../../fakes/fake_notifications_repository.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:social_app/features/notifications/data/models/notification_model.dart';
import 'package:social_app/features/notifications/domain/use_cases/notifications_use_case.dart';


void main() {
  late FakeNotificationsRepository fakeRepo;
  late FakeFirebaseFirestore fakeFirestore;
  late MockSessionService mockSession;
  late NotificationsUseCase useCase;

  setUp(() {
    mockSession = MockSessionService();
    fakeFirestore = FakeFirebaseFirestore();
    fakeRepo = FakeNotificationsRepository();
    when(() => mockSession.currentUid).thenReturn('uid-1');
    useCase = NotificationsUseCase(
      repository: fakeRepo,
      sessionService: mockSession,
    );
  });

  group('executeGetNotificationsStream', () {
    test('calls getNotificationsStream with currentUid', () async {
      final snapshot = await fakeFirestore.collection('notifications').get();
      fakeRepo.notificationsStream = Stream.value(snapshot);
      fakeRepo.convertResult = [];

      await useCase
          .executeGetNotificationsStream()
          .first;

      expect(fakeRepo.getNotificationsStreamCallCount, 1);
      expect(fakeRepo.lastNotificationsStreamUserId, 'uid-1');
    });

    test('calls convertNotificationsToModels with snapshot', () async {
      final snapshot = await fakeFirestore.collection('notifications').get();
      fakeRepo.notificationsStream = Stream.value(snapshot);
      fakeRepo.convertResult = [];

      await useCase
          .executeGetNotificationsStream()
          .first;

      expect(fakeRepo.convertCallCount, 1);
    });

    test('emits converted NotificationsModel list', () async {
      final snapshot = await fakeFirestore.collection('notifications').get();
      fakeRepo.notificationsStream = Stream.value(snapshot);
      fakeRepo.convertResult = [
        NotificationsModel.empty(),
        NotificationsModel.empty(),
      ];

      final result = await useCase
          .executeGetNotificationsStream()
          .first;

      expect(result.length, 2);
    });

    test('emits empty list when no notifications', () async {
      final snapshot = await fakeFirestore.collection('notifications').get();
      fakeRepo.notificationsStream = Stream.value(snapshot);
      fakeRepo.convertResult = [];

      final result = await useCase
          .executeGetNotificationsStream()
          .first;

      expect(result, isEmpty);
    });

    test('uses updated currentUid', () async {
      when(() => mockSession.currentUid).thenReturn('custom-uid');
      final snapshot = await fakeFirestore.collection('notifications').get();
      fakeRepo.notificationsStream = Stream.value(snapshot);
      fakeRepo.convertResult = [];

      await useCase
          .executeGetNotificationsStream()
          .first;

      expect(fakeRepo.lastNotificationsStreamUserId, 'custom-uid');
    });

    test('propagates errors from convertNotificationsToModels', () async {
      final snapshot = await fakeFirestore.collection('notifications').get();
      fakeRepo.notificationsStream = Stream.value(snapshot);
      fakeRepo.convertError = Exception('convert failed');

      expect(
            () =>
        useCase
            .executeGetNotificationsStream()
            .first,
        throwsA(isA<Exception>()),
      );
    });
  });

  group('executeUpdateNotificationsCounter', () {
    test('calls updateNotificationReadStatus with docId', () async {
      await useCase.executeUpdateNotificationsCounter(docId: 'notif-1');

      expect(fakeRepo.updateCallCount, 1);
      expect(fakeRepo.lastUpdateDocId, 'notif-1');
    });

    test('uses different docId correctly', () async {
      await useCase.executeUpdateNotificationsCounter(docId: 'custom-doc');

      expect(fakeRepo.lastUpdateDocId, 'custom-doc');
    });

    test('propagates errors from repository', () async {
      fakeRepo.updateError = Exception('update failed');

      expect(
            () => useCase.executeUpdateNotificationsCounter(docId: 'notif-1'),
        throwsA(isA<Exception>()),
      );
    });
  });
}