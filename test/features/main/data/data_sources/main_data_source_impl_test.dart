import 'package:flutter_test/flutter_test.dart';
import 'package:social_app/core/constants/app_strings.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:social_app/core/constants/firestore_schema.dart';
import 'package:social_app/features/main/data/data_sources/main_data_source_impl.dart';


void main() {
  late FakeFirebaseFirestore fakeFirestore;
  late MainDataSourceImpl dataSource;

  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
    dataSource = MainDataSourceImpl(firestore: fakeFirestore);
  });

  group('getAllUsersExceptCurrent', () {
    test('returns all users except current user', () async {
      await fakeFirestore.collection(FirestoreSchema.users).doc('uid-1').set({
        AppStrings.userId: 'uid-1',
        AppStrings.userName: 'Ali',
      });
      await fakeFirestore.collection(FirestoreSchema.users).doc('uid-2').set({
        AppStrings.userId: 'uid-2',
        AppStrings.userName: 'Sara',
      });
      await fakeFirestore.collection(FirestoreSchema.users).doc('uid-3').set({
        AppStrings.userId: 'uid-3',
        AppStrings.userName: 'Omar',
      });

      final result = await dataSource.getAllUsersExceptCurrent(uId: 'uid-1');

      expect(result.docs.length, 2);
      expect(
        result.docs.every((d) => d.data()[AppStrings.userId] != 'uid-1'),
        true,
      );
    });

    test('returns empty when only current user exists', () async {
      await fakeFirestore.collection(FirestoreSchema.users).doc('uid-1').set({
        AppStrings.userId: 'uid-1',
      });

      final result = await dataSource.getAllUsersExceptCurrent(uId: 'uid-1');

      expect(result.docs, isEmpty);
    });

    test('returns empty when no users', () async {
      final result = await dataSource.getAllUsersExceptCurrent(uId: 'uid-1');

      expect(result.docs, isEmpty);
    });
  });

  group('getUnreadNotifications', () {
    test('returns only unread notifications', () async {
      await fakeFirestore.collection(FirestoreSchema.notifications).doc('n1').set({
        AppStrings.isRead: false,
        AppStrings.userId: 'uid-1',
      });
      await fakeFirestore.collection(FirestoreSchema.notifications).doc('n2').set({
        AppStrings.isRead: false,
        AppStrings.userId: 'uid-1',
      });
      await fakeFirestore.collection(FirestoreSchema.notifications).doc('n3').set({
        AppStrings.isRead: true,  // ← read
        AppStrings.userId: 'uid-1',
      });

      final result = await dataSource.getUnreadNotifications();

      expect(result.docs.length, 2);
      expect(
        result.docs.every((d) => d.data()[AppStrings.isRead] == false),
        true,
      );
    });

    test('returns empty when all notifications are read', () async {
      await fakeFirestore.collection(FirestoreSchema.notifications).doc('n1').set({
        AppStrings.isRead: true,
      });

      final result = await dataSource.getUnreadNotifications();

      expect(result.docs, isEmpty);
    });
  });

  group('getNotificationsStream', () {
    test('emits only unread notifications', () async {
      await fakeFirestore.collection(FirestoreSchema.notifications).doc('n1').set({
        AppStrings.isRead: false,
      });
      await fakeFirestore.collection(FirestoreSchema.notifications).doc('n2').set({
        AppStrings.isRead: true,
      });

      final stream = dataSource.getNotificationsStream();
      final snapshot = await stream.first;

      expect(snapshot.docs.length, 1);
      expect(snapshot.docs.first.data()[AppStrings.isRead], false);
    });

    test('emits empty when no unread notifications', () async {
      await fakeFirestore.collection(FirestoreSchema.notifications).doc('n1').set({
        AppStrings.isRead: true,
      });

      final stream = dataSource.getNotificationsStream();
      final snapshot = await stream.first;

      expect(snapshot.docs, isEmpty);
    });

    test('emits updated snapshot after mark as read', () async {
      await fakeFirestore.collection(FirestoreSchema.notifications).doc('n1').set({
        AppStrings.isRead: false,
      });

      final stream = dataSource.getNotificationsStream();
      final first = await stream.first;
      expect(first.docs.length, 1);

      await fakeFirestore.collection(FirestoreSchema.notifications).doc('n1').update({
        AppStrings.isRead: true,
      });

      final second = await stream.first;
      expect(second.docs, isEmpty);
    });
  });
}