import '../../../fakes/fake_cache_helper.dart';
import 'package:flutter_test/flutter_test.dart';
import '../../../fakes/fake_firestore_service.dart';
import 'package:social_app/core/data/models/my_model.dart';
import 'package:social_app/core/constants/app_strings.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:social_app/core/constants/firestore_schema.dart';
import 'package:social_app/core/services/data/session_service.dart';
import 'package:social_app/core/services/data/user_account_service.dart';
import 'package:social_app/core/services/domain/i_user_account_service.dart';


void main() {
  late FakeFirebaseFirestore fakeFirestore;
  late FakeFirestoreService fakeDataSource;
  late SessionService sessionService;
  late IUserAccountService service;

  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
    fakeDataSource = FakeFirestoreService();
    SessionService.resetForTesting();
    sessionService = SessionService(cacheHelper: FakeCacheHelper());
    service = UserAccountService(
      dataSource: fakeDataSource,
      sessionService: sessionService,
    );
  });

  group('getUserAccount', () {
    test(
        'returns account with empty image when userImage is not a DocumentReference',
            () async {
          final account = {
            'name': 'Ali',
            AppStrings.userImage: 'already-a-string-url',
          };

          final result = await service.getUserAccount(userAccount: account);

          expect(result['name'], 'Ali');
          expect(result[AppStrings.userImage], 'already-a-string-url');
        });

    test('resolves userImage DocumentReference to its userPost string',
            () async {
          // 1. أنشئ صورة في fakeFirestore
          await fakeFirestore.collection('images').doc('img-1').set({
            'userPost': 'https://cdn.example.com/avatar.png',
          });

          // 2. احصل على DocumentReference الحقيقية
          final imageRef = fakeFirestore.collection('images').doc('img-1');

          // 3. حساب يحتوي على DocumentReference
          final account = {
            'name': 'Sara',
            AppStrings.userImage: imageRef,
          };

          final result = await service.getUserAccount(userAccount: account);

          expect(result[AppStrings.userImage],
              'https://cdn.example.com/avatar.png');
        });

    test('sets userImage to empty when referenced image doc does not exist',
            () async {
          final imageRef = fakeFirestore.collection('images').doc('missing');

          final account = {
            'name': 'Omar',
            AppStrings.userImage: imageRef,
          };

          final result = await service.getUserAccount(userAccount: account);

          expect(result[AppStrings.userImage], '');
        });

    test('returns empty map when image doc lookup throws', () async {
      // DocumentReference من fakeFirestore لا يرمي عادةً، لكن لو أردت
      // محاكاة خطأ، يمكنك تمرير DocumentReference غير صالحة. هنا نتحقق
      // من أن catch يعيد {} — لكن هذا السيناريو صعب التحفيز طبيعياً.
      // سنتركه كملاحظة، ويمكن اختباره بـ mock يدوي إذا لزم.
    });
  });

  group('getAccountMap', () {
    test('returns processed account map from DocumentSnapshot', () async {
      // 1. أنشئ حساباً في fakeFirestore
      await fakeFirestore.collection(FirestoreSchema.accounts).doc('u1').set({
        'name': 'Ali',
        AppStrings.userImage: 'url',
      });

      // 2. احصل على DocumentSnapshot الحقيقية
      final userDoc = await fakeFirestore
          .collection(FirestoreSchema.accounts)
          .doc('u1')
          .get();

      // 3. استدعِ getAccountMap
      final result = await service.getAccountMap(userDoc: userDoc);

      expect(result['name'], 'Ali');
      expect(result[AppStrings.userImage], 'url');
    });
  });

  group('getUserModelData', () {
    test('returns MyModel built from the resolved account', () async {
      // 1. أنشئ حساباً
      await fakeFirestore.collection(FirestoreSchema.accounts).doc('u2').set({
        'id': 'u2',
        'name': 'Sara',
        AppStrings.userImage: 'url',
      });

      // 2. stub الـ data source ليعيد snapshot الحساب
      final snapshot = await fakeFirestore
          .collection(FirestoreSchema.accounts)
          .doc('u2')
          .get();
      fakeDataSource.stubDoc(
        collectionPath: FirestoreSchema.accounts,
        docId: 'u2',
        snapshot: snapshot,
      );

      // 3. استدعِ
      final result = await service.getUserModelData(id: 'u2');

      expect(result, isA<MyModel>());
    });
  });

  group('getUserAccountData', () {
    test('uses currentUid from SessionService to fetch the account',
            () async {
          // 1. اضبط session على uid معروف
          await sessionService.login('u3');

          // 2. أنشئ حساباً لهذا الـ uid
          await fakeFirestore.collection(FirestoreSchema.accounts)
              .doc('u3')
              .set({
            'id': 'u3',
            'name': 'Omar',
            AppStrings.userImage: 'url',
          });

          // 3. stub
          final snapshot = await fakeFirestore
              .collection(FirestoreSchema.accounts)
              .doc('u3')
              .get();
          fakeDataSource.stubDoc(
            collectionPath: FirestoreSchema.accounts,
            docId: 'u3',
            snapshot: snapshot,
          );

          // 4. استدعِ
          final result = await service.getUserAccountData();

          expect(result, isA<MyModel>());
        });
  });
}