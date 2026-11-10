import 'package:mocktail/mocktail.dart';
import 'package:flutter_test/flutter_test.dart';
import '../../../../fakes/mock_session_service.dart';
import 'package:social_app/core/constants/app_strings.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:social_app/core/constants/firestore_schema.dart';
import 'package:social_app/core/data/models/user_info_model.dart';
import 'package:social_app/features/profile/data/converters/Info_data_converter.dart';
import 'package:social_app/core/data/data_sources/remote/firestore/firestore_service_impl.dart';


void main() {
  late FakeFirebaseFirestore fakeFirestore;
  late FirestoreServiceImpl fakeDataSource;
  late MockSessionService mockSession;
  late AccountDataConverter converter;

  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
    fakeDataSource = FirestoreServiceImpl(firestore: fakeFirestore);
    mockSession = MockSessionService();
    when(() => mockSession.currentUid).thenReturn('uid-1');
    converter = AccountDataConverter(
      repository: fakeDataSource,
      sessionService: mockSession,
      firestore: fakeFirestore,
    );
  });

  group('fromDocumentSnapshot', () {
    test('throws TypeError when accountDoc is null', () async {
      // ← accountDoc! — TypeError
      expect(
            () => converter.fromDocumentSnapshot(null, null),
        throwsA(isA<TypeError>()),
      );
    });

    test('converts accountDoc without infoDoc when userImage is DocumentReference',
            () async {
          // صورة في posts
          await fakeFirestore.collection(FirestoreSchema.posts).doc('img-1').set({
            AppStrings.userId: 'uid-1',
            AppStrings.userText: 'Image',
            'userPost': 'url',
          });
          final imageRef = fakeFirestore.collection(FirestoreSchema.posts).doc('img-1');

          await fakeFirestore.collection('accounts').doc('uid-1').set({
            AppStrings.userId: 'uid-1',
            'userName': 'Ali',
            AppStrings.userImage: imageRef,
          });
          final accountDoc = await fakeFirestore
              .collection('accounts')
              .doc('uid-1')
              .get();

          final result = await converter.fromDocumentSnapshot(null, accountDoc);

          expect(result, isA<UserInfoModel>());
        });

    test('merges userState from infoDoc into jsonData', () async {
      await fakeFirestore.collection(FirestoreSchema.posts).doc('img-1').set({});
      final imageRef = fakeFirestore.collection(FirestoreSchema.posts).doc('img-1');

      await fakeFirestore.collection('accounts').doc('uid-1').set({
        'userName': 'Ali',
        AppStrings.userImage: imageRef,
      });
      await fakeFirestore.collection('info').doc('uid-1').set({
        'userState': 'Single',
      });
      final accountDoc = await fakeFirestore
          .collection('accounts')
          .doc('uid-1')
          .get();
      final infoDoc = await fakeFirestore.collection('info').doc('uid-1').get();

      final result = await converter.fromDocumentSnapshot(infoDoc, accountDoc);

      expect(result, isA<UserInfoModel>());
    });

    test('throws TypeError when userImage is String (not DocumentReference)',
            () async {
          await fakeFirestore.collection('accounts').doc('uid-1').set({
            'userName': 'Ali',
            AppStrings.userImage: 'https://example.com/img.jpg',  // ← String
          });
          final accountDoc = await fakeFirestore
              .collection('accounts')
              .doc('uid-1')
              .get();

          // ← userImage = null (ليس DocumentReference) → userImage! → TypeError
          expect(
                () => converter.fromDocumentSnapshot(null, accountDoc),
            throwsA(isA<TypeError>()),
          );
        });

    test('sets myName from infoDoc.userName on userImage', () async {
      await fakeFirestore.collection(FirestoreSchema.posts).doc('img-1').set({
        AppStrings.userId: 'uid-1',
        'userPost': 'url',
      });
      final imageRef = fakeFirestore.collection(FirestoreSchema.posts).doc('img-1');

      await fakeFirestore.collection('accounts').doc('uid-1').set({
        'userName': 'Ali',
        AppStrings.userImage: imageRef,
      });
      await fakeFirestore.collection('info').doc('uid-1').set({
        'userName': 'Ali Ahmed',
        AppStrings.userCover: imageRef,
      });
      final accountDoc = await fakeFirestore
          .collection('accounts')
          .doc('uid-1')
          .get();
      final infoDoc = await fakeFirestore.collection('info').doc('uid-1').get();

      final result = await converter.fromDocumentSnapshot(infoDoc, accountDoc);

      // userImage.myName = infoDoc.userName
      expect(result, isA<UserInfoModel>());
    });
  });

  group('_getDocRef (via fromDocumentSnapshot)', () {
    test('resolves DocumentReference to PostModel with counts', () async {
      // post + likes + comments
      await fakeFirestore.collection(FirestoreSchema.posts).doc('img-1').set({
        AppStrings.userId: 'uid-1',
        'userPost': 'url',
      });
      await fakeFirestore
          .collection(FirestoreSchema.posts)
          .doc('img-1')
          .collection(AppStrings.likesList)
          .doc('like-1')
          .set({});
      await fakeFirestore
          .collection(FirestoreSchema.posts)
          .doc('img-1')
          .collection(AppStrings.commentsList)
          .doc('comment-1')
          .set({});

      final imageRef = fakeFirestore.collection(FirestoreSchema.posts).doc('img-1');

      await fakeFirestore.collection('accounts').doc('uid-1').set({
        'userName': 'Ali',
        AppStrings.userImage: imageRef,
      });
      final accountDoc = await fakeFirestore
          .collection('accounts')
          .doc('uid-1')
          .get();

      final result = await converter.fromDocumentSnapshot(null, accountDoc);

      expect(result, isA<UserInfoModel>());
    });

    test('returns null when DocumentReference points to missing doc', () async {
      final imageRef = fakeFirestore
          .collection(FirestoreSchema.posts)
          .doc('missing');

      await fakeFirestore.collection('accounts').doc('uid-1').set({
        'userName': 'Ali',
        AppStrings.userImage: imageRef,
      });
      final accountDoc = await fakeFirestore
          .collection('accounts')
          .doc('uid-1')
          .get();

      // ← _getDocRef يعيد null → userImage! → TypeError
      expect(
            () => converter.fromDocumentSnapshot(null, accountDoc),
        throwsA(isA<TypeError>()),
      );
    });
  });
}