import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:social_app/core/domain/data_sources/remote/auth_service.dart';
import 'package:social_app/core/data/data_sources/remote/auth_service_impl.dart';


void main() {
  late AuthService authService;
  late MockFirebaseAuth mockAuth;

  setUp(() {
    mockAuth = MockFirebaseAuth(
      mockUser: MockUser(email: 'existing@test.com', uid: 'uid-123'),
    );
    authService = AuthServiceImpl(auth: mockAuth);
  });

  test('signIn returns UserCredential with correct uid', () async {
    final result = await authService.signIn(
      email: 'existing@test.com',
      password: 'password123',
    );
    expect(result.user?.uid, 'uid-123');
  });

  test('signUp creates a new user', () async {
    final result = await authService.signUp(
      email: 'new@test.com',
      password: 'password123',
    );
    expect(result.user?.email, 'new@test.com');
  });

  test('signOut completes without error', () async {
    await expectLater(authService.signOut(), completes);
  });
}