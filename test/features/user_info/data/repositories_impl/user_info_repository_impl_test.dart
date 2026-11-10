import 'package:flutter_test/flutter_test.dart';
import '../../../../fakes/fake_firestore_service.dart';
import 'package:social_app/core/data/models/profile_info.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:social_app/features/user_info/domain/repositories/user_info_repository.dart';
import 'package:social_app/features/user_info/data/repositories_impl/user_info_repository_impl.dart';


void main() {
  late UserInfoRepository repository;
  late FakeFirebaseFirestore fakeFirestore;
  late FakeFirestoreService fakeDataSource;

  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
    fakeDataSource = FakeFirestoreService();
    repository = UserInfoRepositoryImpl(dataSource: fakeDataSource);
  });

  group('getInfo', () {
    test('returns user info map when document exists', () async {
      await fakeFirestore.collection('info').doc('uid-123').set({
        'userState': 'Single',
        'userWork': 'Engineer',
        'userLive': 'Cairo',
        'userFrom': 'Egypt',
        'userRelational': 'Single',
      });
      final doc = await fakeFirestore.collection('info').doc('uid-123').get();
      fakeDataSource.stubDoc(
        collectionPath: 'info',
        docId: 'uid-123',
        snapshot: doc,
      );

      final result = await repository.getInfo(uId: 'uid-123');

      expect(result['userState'], 'Single');
      expect(result['userWork'], 'Engineer');
      expect(result['userLive'], 'Cairo');
      expect(result['userFrom'], 'Egypt');
      expect(result['userRelational'], 'Single');
    });

    test('returns empty map when document does not exist', () async {
      final missingDoc = await fakeFirestore
          .collection('info')
          .doc('missing')
          .get();
      fakeDataSource.stubDoc(
        collectionPath: 'info',
        docId: 'missing',
        snapshot: missingDoc,
      );

      final result = await repository.getInfo(uId: 'missing');

      expect(result, isEmpty);
    });

    test('calls getDoc with "info" and uId', () async {
      await fakeFirestore.collection('info').doc('uid-123').set({
        'userState': 'Single',
      });
      final doc = await fakeFirestore.collection('info').doc('uid-123').get();
      fakeDataSource.stubDoc(
        collectionPath: 'info',
        docId: 'uid-123',
        snapshot: doc,
      );

      await repository.getInfo(uId: 'uid-123');

      expect(fakeDataSource.docs['info/uid-123'], isNotNull);
    });

    test('propagates errors from getDoc', () async {
      expect(
            () => repository.getInfo(uId: 'missing'),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('updateProfileInfo', () {
    test('calls setSupDoc with "info" collection and isMerge true', () async {
      final profileInfo = ProfileInfo(
        userState: 'Single',
        userWork: 'Engineer',
        userLive: 'Cairo',
        userFrom: 'Egypt',
        userRelational: 'Single',
      );

      await repository.updateProfileInfo(
        docId: 'uid-123',
        infoModel: profileInfo,
      );

      expect(fakeDataSource.setSupDocCallCount, 1);
      expect(fakeDataSource.lastSetSupCollectionPath, 'info');
      expect(fakeDataSource.lastSetSupDocId, 'uid-123');
      expect(fakeDataSource.lastSetSupIsMerge, true); // ← isMerge
    });

    test('passes infoModel.toJson() as data', () async {
      final profileInfo = ProfileInfo(
        userState: 'Single',
        userWork: 'Engineer',
        userLive: 'Cairo',
        userFrom: 'Egypt',
        userRelational: 'Single',
      );

      await repository.updateProfileInfo(
        docId: 'uid-123',
        infoModel: profileInfo,
      );

      expect(fakeDataSource.lastSetSupData, profileInfo.toJson());
      expect(fakeDataSource.lastSetSupData!['userState'], 'Single');
      expect(fakeDataSource.lastSetSupData!['userWork'], 'Engineer');
      expect(fakeDataSource.lastSetSupData!['userLive'], 'Cairo');
      expect(fakeDataSource.lastSetSupData!['userFrom'], 'Egypt');
      expect(fakeDataSource.lastSetSupData!['userRelational'], 'Single');
    });

    test('does not include coverImage in toJson (documents behavior)',
            () async {
          final profileInfo = ProfileInfo(
            userState: 'Single',
            userWork: 'Engineer',
            userLive: 'Cairo',
            userFrom: 'Egypt',
            userRelational: 'Single',
          );

          await repository.updateProfileInfo(
            docId: 'uid-123',
            infoModel: profileInfo,
          );

          // toJson لا يتضمن coverImage
          expect(
              fakeDataSource.lastSetSupData!.containsKey('coverImage'), false);
          expect(
              fakeDataSource.lastSetSupData!.containsKey('userCover'), false);
        });

    test('propagates errors from setSupDoc', () async {
      fakeDataSource.setSupDocError = Exception('write failed');
      final profileInfo = ProfileInfo(
        userState: 'Single',
        userWork: 'Engineer',
        userLive: 'Cairo',
        userFrom: 'Egypt',
        userRelational: 'Single',
      );

      expect(
            () =>
            repository.updateProfileInfo(
              docId: 'uid-123',
              infoModel: profileInfo,
            ),
        throwsA(isA<Exception>()),
      );
    });
  });
}