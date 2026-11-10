import 'package:flutter_test/flutter_test.dart';
import '../../../../fakes/fake_firestore_service.dart';
import 'package:social_app/core/data/models/user_account.dart';
import 'package:social_app/core/constants/firestore_schema.dart';
import 'package:social_app/features/auth/domain/repositories/sign_up_repository.dart';
import 'package:social_app/features/auth/data/repositories_impl/sign_up_repository_impl.dart';


void main() {
  late SignUpRepository repository;
  late FakeFirestoreService fakeDataSource;

  setUp(() {
    fakeDataSource = FakeFirestoreService();
    repository = SignUpRepositoryImpl(dataSource: fakeDataSource);
  });

  group('createUserInfo', () {
    test('calls setSupDoc with FirestoreSchema.accounts', () async {
      final userAccount = UserAccount(
        userId: 'uid-123',
        firstName: 'Ali',
        lastName: 'Ahmed',
        fullName: 'Ali Ahmed',
      );

      await repository.createUserInfo(userModel: userAccount);

      expect(fakeDataSource.setSupDocCallCount, 1);
      expect(fakeDataSource.lastSetSupCollectionPath, FirestoreSchema.accounts);
    });

    test('passes userId as docId', () async {
      final userAccount = UserAccount(
        userId: 'uid-123',
        firstName: 'Ali',
        lastName: 'Ahmed',
        fullName: 'Ali Ahmed',
      );

      await repository.createUserInfo(userModel: userAccount);

      expect(fakeDataSource.lastSetSupDocId, 'uid-123');
    });

    test('passes isMerge false', () async {
      final userAccount = UserAccount(
        userId: 'uid-123',
        firstName: 'Ali',
        lastName: 'Ahmed',
        fullName: 'Ali Ahmed',
      );

      await repository.createUserInfo(userModel: userAccount);

      expect(fakeDataSource.lastSetSupIsMerge, false);
    });

    test('passes userModel.toJson() as data', () async {
      final userAccount = UserAccount(
        userId: 'uid-123',
        firstName: 'Ali',
        lastName: 'Ahmed',
        fullName: 'Ali Ahmed',
      );

      await repository.createUserInfo(userModel: userAccount);

      expect(fakeDataSource.lastSetSupData, userAccount.toJson());
      expect(fakeDataSource.lastSetSupData!['userId'], 'uid-123');
      expect(fakeDataSource.lastSetSupData!['firstName'], 'Ali');
      expect(fakeDataSource.lastSetSupData!['fullName'], 'Ali Ahmed');
    });

    test('propagates errors from setSupDoc', () async {
      fakeDataSource.setSupDocError = Exception('write failed');
      final userAccount = UserAccount(
        userId: 'uid-123',
        firstName: 'Ali',
        lastName: 'Ahmed',
        fullName: 'Ali Ahmed',
      );

      expect(
            () => repository.createUserInfo(userModel: userAccount),
        throwsA(isA<Exception>()),
      );
    });
  });
}