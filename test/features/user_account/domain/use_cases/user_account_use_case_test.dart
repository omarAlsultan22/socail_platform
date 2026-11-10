import 'package:mocktail/mocktail.dart';
import 'package:flutter_test/flutter_test.dart';
import '../../../../fakes/mock_session_service.dart';
import '../../../../fakes/fake_user_account_repository.dart';
import 'package:social_app/core/data/models/user_account.dart';
import 'package:social_app/features/user_account/domain/use_cases/user_account_use_case.dart';


void main() {
  late FakeUserAccountRepository fakeRepo;
  late MockSessionService mockSession;
  late UserAccountUseCase useCase;

  setUp(() {
    fakeRepo = FakeUserAccountRepository();
    mockSession = MockSessionService();
    when(() => mockSession.currentUid).thenReturn('uid-1');
    useCase = UserAccountUseCase(
      repository: fakeRepo,
      sessionService: mockSession,
    );
  });

  group('executeGetAccount', () {
    test('calls getAccount with currentUid', () async {
      await useCase.executeGetAccount();

      expect(fakeRepo.getAccountCallCount, 1);
      expect(fakeRepo.lastGetAccountUid, 'uid-1');
    });

    test('returns UserAccount from repository', () async {
      final expected = UserAccount(
        userId: 'uid-1',
        firstName: 'Sara',
        lastName: 'Mohamed',
        fullName: 'Sara Mohamed',
      );
      fakeRepo.getAccountResult = expected;

      final result = await useCase.executeGetAccount();

      expect(result, same(expected));
    });

    test('uses updated currentUid', () async {
      when(() => mockSession.currentUid).thenReturn('custom-uid-456');

      await useCase.executeGetAccount();

      expect(fakeRepo.lastGetAccountUid, 'custom-uid-456');
    });

    test('propagates errors from getAccount', () async {
      fakeRepo.getAccountError = Exception('fetch failed');

      expect(
            () => useCase.executeGetAccount(),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('executeUpdateAccount', () {
    test('calls updateAccount with correct UserAccount', () async {
      await useCase.executeUpdateAccount(
        firstName: 'Ali',
        lastName: 'Ahmed',
      );

      expect(fakeRepo.updateAccountCallCount, 1);
      final userAccount = fakeRepo.lastUpdateUserAccount!;
      expect(userAccount.firstName, 'Ali');
      expect(userAccount.lastName, 'Ahmed');
      expect(userAccount.fullName, 'Ali Ahmed'); // ← مع مسافة
      expect(userAccount.userId, 'uid-1');
    });

    test('uses currentUid for userId', () async {
      when(() => mockSession.currentUid).thenReturn('custom-uid-789');

      await useCase.executeUpdateAccount(
        firstName: 'Sara',
        lastName: 'Mohamed',
      );

      expect(fakeRepo.lastUpdateUserAccount!.userId, 'custom-uid-789');
    });

    test('builds fullName with space between firstName and lastName',
            () async {
          await useCase.executeUpdateAccount(
            firstName: 'Ali',
            lastName: 'Ahmed',
          );

          // 'Ali Ahmed' — مع مسافة
          expect(fakeRepo.lastUpdateUserAccount!.fullName, 'Ali Ahmed');
          expect(fakeRepo.lastUpdateUserAccount!.fullName, contains(' '));
        });

    test('propagates errors from updateAccount', () async {
      fakeRepo.updateAccountError = Exception('update failed');

      expect(
            () =>
            useCase.executeUpdateAccount(
              firstName: 'Ali',
              lastName: 'Ahmed',
            ),
        throwsA(isA<Exception>()),
      );
    });
  });
}