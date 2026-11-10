import 'package:mocktail/mocktail.dart';
import 'package:flutter_test/flutter_test.dart';
import '../../../../fakes/mock_session_service.dart';
import 'package:social_app/core/data/models/my_model.dart';
import '../../../../fakes/fake_friendship_repository.dart';
import 'package:social_app/core/errors/exceptions/validation_exception.dart';
import 'package:social_app/features/friendship/domain/use_cases/friendship_use_case.dart';


void main() {
  late FakeFriendshipRepository fakeRepo;
  late MockSessionService mockSession;
  late FriendshipUseCase useCase;

  setUp(() {
    mockSession = MockSessionService();
    fakeRepo = FakeFriendshipRepository();
    when(() => mockSession.currentUid).thenReturn('uid-1');
    useCase = FriendshipUseCase(
      repository: fakeRepo,
      sessionService: mockSession,
    );
  });

  group('executeAddFriendRequest (bug: throws for valid uId)', () {
    test('throws when uId is null (documents TypeError bug)', () async {
      // ⚠️ bug: uId == null → uId! → TypeError (not ValidationException)
      expect(
            () => useCase.executeAddFriendRequest(uId: null),
        throwsA(isA<TypeError>()), // ← bug: TypeError بدل ValidationException
      );
    });

    test('throws when uId is valid (documents inverted logic bug)', () async {
      // ⚠️ bug: uId != null → throw (should NOT throw)
      expect(
            () => useCase.executeAddFriendRequest(uId: 'friend-uid'),
        throwsA(isA<ValidationException>()),
      );
    });
  });

  group('executeConfirmNewFriend', () {
    test('throws when uId is null', () async {
      expect(
            () => useCase.executeConfirmNewFriend(uId: null),
        throwsA(isA<TypeError>()),
      );
    });

    test('throws for valid uId (bug)', () async {
      expect(
            () => useCase.executeConfirmNewFriend(uId: 'friend-uid'),
        throwsA(isA<ValidationException>()),
      );
    });
  });

  group('executeDeclineFriendRequest', () {
    test('throws when uId is null', () async {
      expect(
            () => useCase.executeDeclineFriendRequest(uId: null),
        throwsA(isA<TypeError>()),
      );
    });

    test('throws for valid uId (bug)', () async {
      expect(
            () => useCase.executeDeclineFriendRequest(uId: 'friend-uid'),
        throwsA(isA<ValidationException>()),
      );
    });
  });

  group('executeGetConversationsStream', () {
    test('delegates to repository with currentUid', () async {
      fakeRepo.conversationsStream = const Stream.empty();

      useCase.executeGetConversationsStream(
        getUserModelData: (id) async =>
            MyModel(myId: id, myDateTime: DateTime(2024)),
      );

      expect(fakeRepo.getConversationsStreamCallCount, 1);
      expect(fakeRepo.lastUserId, 'uid-1');
    });

    test('passes getUserModelData to repository', () async {
      fakeRepo.conversationsStream = const Stream.empty();
      Future<MyModel> getUserModelData(String id) async =>
          MyModel(myId: id, myDateTime: DateTime(2024));

      useCase.executeGetConversationsStream(
        getUserModelData: getUserModelData,
      );

      expect(fakeRepo.lastGetUserModelData, same(getUserModelData));
    });
  });
}