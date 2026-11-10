import 'package:flutter_test/flutter_test.dart';
import '../../../../fakes/fake_firestore_service.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:social_app/core/data/models/user_account.dart';
import 'package:social_app/core/constants/firestore_schema.dart';
import 'package:social_app/core/errors/exceptions/validation_exception.dart';
import 'package:social_app/features/user_account/domain/repositories/user_account_repository.dart';
import 'package:social_app/features/user_account/data/repositories_impl/user_account_repository_impl.dart';


void main() {
  late FakeFirebaseFirestore fakeFirestore;
  late FakeFirestoreService fakeDataSource;
  late UserAccountRepository repository;

  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
    fakeDataSource = FakeFirestoreService();
    repository = UserAccountRepositoryImpl(dataSource: fakeDataSource);
  });

  group('getAccount', () {
    test('returns UserAccount when document exists', () async {
      await fakeFirestore.collection(FirestoreSchema.accounts).doc('uid-1').set(
          {
            'userId': 'uid-1',
            'firstName': 'Ali',
            'lastName': 'Ahmed',
            'fullName': 'Ali Ahmed',
          });
      final docRef =
      fakeFirestore.collection(FirestoreSchema.accounts).doc('uid-1');
      fakeDataSource.docRefToReturn = docRef;

      final result = await repository.getAccount('uid-1');

      expect(result, isA<UserAccount>());
      expect(result.userId, 'uid-1');
      expect(result.firstName, 'Ali');
    });

    test('calls getDocRef with accounts collection and uId', () async {
      await fakeFirestore.collection(FirestoreSchema.accounts).doc('uid-1').set(
          {
            'userId': 'uid-1',
          });
      final docRef =
      fakeFirestore.collection(FirestoreSchema.accounts).doc('uid-1');
      fakeDataSource.docRefToReturn = docRef;

      await repository.getAccount('uid-1');

      expect(fakeDataSource.getDocRefCallCount, 1);
      expect(fakeDataSource.lastGetDocRefDocId, 'uid-1');
      expect(
          fakeDataSource.lastGetDocRefCollectionPath, FirestoreSchema.accounts);
    });

    test('throws ValidationException when document does not exist', () async {
      final docRef =
      fakeFirestore.collection(FirestoreSchema.accounts).doc('missing');
      fakeDataSource.docRefToReturn = docRef;

      expect(
            () => repository.getAccount('missing'),
        throwsA(isA<ValidationException>()),
      );
    });
  });

  group('updateAccount', () {
    test('calls updateDoc with correct params', () async {
      final userAccount = UserAccount(
        userId: 'uid-1',
        firstName: 'Ali',
        lastName: 'Ahmed',
        fullName: 'Ali Ahmed',
      );

      await repository.updateAccount(userAccount: userAccount);

      expect(fakeDataSource.updateDocCallCount, 1);
      expect(fakeDataSource.lastUpdateDocDocId, 'uid-1');
      expect(
          fakeDataSource.lastUpdateDocCollectionPath, FirestoreSchema.accounts);
    });

    test('passes userAccount.toJson() as data', () async {
      final userAccount = UserAccount(
        userId: 'uid-1',
        firstName: 'Ali',
        lastName: 'Ahmed',
        fullName: 'Ali Ahmed',
      );

      await repository.updateAccount(userAccount: userAccount);

      expect(fakeDataSource.lastUpdateDocData, userAccount.toJson());
      expect(fakeDataSource.lastUpdateDocData!['firstName'], 'Ali');
      expect(fakeDataSource.lastUpdateDocData!['fullName'], 'Ali Ahmed');
    });

    test('propagates errors from updateDoc', () async {
      fakeDataSource.updateDocError = Exception('update failed');
      final userAccount = UserAccount(
        userId: 'uid-1',
        firstName: 'Ali',
        lastName: 'Ahmed',
        fullName: 'Ali Ahmed',
      );

      expect(
            () => repository.updateAccount(userAccount: userAccount),
        throwsA(isA<Exception>()),
      );
    });
  });
}