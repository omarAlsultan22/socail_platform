import 'package:mocktail/mocktail.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../fakes/fake_cache_helper.dart';
import '../../../../fakes/fake_auth_repository.dart';
import '../../../../fakes/mock_session_service.dart';
import '../../../../fakes/mock_user_credential.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:social_app/features/auth/domain/use_cases/sign_in_use_case.dart';


void main() {
  late FakeAuthRepository fakeRepo;
  late MockSessionService mockSession;
  late FakeCacheHelper fakeCache;
  late SignInUseCase useCase;
  late UserCredential validCredential;

  setUp(() async {
    fakeRepo = FakeAuthRepository();
    mockSession = MockSessionService();
    fakeCache = FakeCacheHelper();
    useCase = SignInUseCase(
      authRepository: fakeRepo,
      sessionService: mockSession,
      cacheHelper: fakeCache,
    );

    final mockAuth = MockFirebaseAuth(
      mockUser: MockUser(uid: 'uid-123', email: 'a@b.com'),
      signedIn: true,
    );
    validCredential = await mockAuth.signInWithEmailAndPassword(
      email: 'a@b.com',
      password: 'p',
    );
  });

  group('signInExecute', () {
    test('passes credentials to authRepository.signIn', () async {
      fakeRepo.signInResult = validCredential;

      when(() => mockSession.login(any())).thenAnswer((_) async {});

      await useCase.signInExecute(
        userEmail: 'a@b.com',
        userPassword: 'password123',
      );

      expect(fakeRepo.signInCallCount, 1);
      expect(fakeRepo.lastSignInEmail, 'a@b.com');
      expect(fakeRepo.lastSignInPassword, 'password123');
    });

    test('calls sessionService.login with user uid', () async {
      fakeRepo.signInResult = validCredential;

      when(() => mockSession.login(any())).thenAnswer((_) async {});

      await useCase.signInExecute(
        userEmail: 'a@b.com',
        userPassword: 'password123',
      );

      verify(() => mockSession.login('uid-123')).called(1);
    });

    test('sets friendsCount to false in cache', () async {
      fakeRepo.signInResult = validCredential;

      when(() => mockSession.login(any())).thenAnswer((_) async {});

      await useCase.signInExecute(
        userEmail: 'a@b.com',
        userPassword: 'password123',
      );

      expect(await fakeCache.getBool(key: 'friendsCount'), false);
    });

    test('throws TypeError when user is null', () async {
      final emptyCredential = MockUserCredential();
      when(() => emptyCredential.user).thenReturn(null);
      fakeRepo.signInResult = emptyCredential;

      expect(
            () =>
            useCase.signInExecute(
              userEmail: 'a@b.com',
              userPassword: 'p',
            ),
        throwsA(isA<TypeError>()), // ← user!
      );

      verifyNever(() => mockSession.login(any()));
    });

    test('propagates errors from authRepository.signIn', () async {
      fakeRepo.signInError = FirebaseAuthException(code: 'wrong-password');

      expect(
            () =>
            useCase.signInExecute(
              userEmail: 'a@b.com',
              userPassword: 'wrong',
            ),
        throwsA(isA<FirebaseAuthException>()),
      );

      verifyNever(() => mockSession.login(any()));
    });

    test('does not set friendsCount when signIn fails', () async {
      fakeRepo.signInError = FirebaseAuthException(code: 'wrong-password');

      try {
        await useCase.signInExecute(
          userEmail: 'a@b.com',
          userPassword: 'wrong',
        );
      } catch (_) {}

      // friendsCount لم يُضبط (getBool يعيد false افتراضي — لكن لم يُستدعَ setBool)
      expect(await fakeCache.getBool(key: 'friendsCount'), isNull);
    });
  });
}