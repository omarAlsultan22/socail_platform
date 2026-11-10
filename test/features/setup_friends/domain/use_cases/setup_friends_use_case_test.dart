import 'package:flutter_test/flutter_test.dart';
import 'package:social_app/core/data/models/my_model.dart';
import '../../../../fakes/fake_setup_friends_repository.dart';
import 'package:social_app/features/setup_friends/domain/use_cases/setup_friends_use_case.dart';


void main() {
  late FakeSetupFriendsRepository fakeRepo;
  late SetupFriendsUseCase useCase;

  setUp(() {
    fakeRepo = FakeSetupFriendsRepository();
    useCase = SetupFriendsUseCase(repository: fakeRepo);
  });

  group('executeGetSuggestsUsers', () {
    test('returns list from repository', () async {
      final expected = [
        MyModel(myId: 'user-1'),
        MyModel(myId: 'user-2'),
      ];
      fakeRepo.getSuggestsUsersResult = expected;

      final result = await useCase.executeGetSuggestsUsers();

      expect(result, same(expected));
      expect(fakeRepo.getSuggestsUsersCallCount, 1);
    });

    test('returns empty list when repository returns empty', () async {
      fakeRepo.getSuggestsUsersResult = [];

      final result = await useCase.executeGetSuggestsUsers();

      expect(result, isEmpty);
    });

    test('propagates errors from repository', () async {
      fakeRepo.getSuggestsUsersError = Exception('fetch failed');

      expect(
            () => useCase.executeGetSuggestsUsers(),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('executeConfirmNewFriend', () {
    test('passes friendId to repository', () async {
      await useCase.executeConfirmNewFriend(friendId: 'friend-uid');

      expect(fakeRepo.confirmNewFriendCallCount, 1);
      expect(fakeRepo.lastFriendId, 'friend-uid');
    });

    test('passes different friendId correctly', () async {
      await useCase.executeConfirmNewFriend(friendId: 'custom-friend-456');

      expect(fakeRepo.lastFriendId, 'custom-friend-456');
    });

    test('propagates errors from repository', () async {
      fakeRepo.confirmNewFriendError = Exception('confirm failed');

      expect(
            () => useCase.executeConfirmNewFriend(friendId: 'friend-uid'),
        throwsA(isA<Exception>()),
      );
    });
  });
}