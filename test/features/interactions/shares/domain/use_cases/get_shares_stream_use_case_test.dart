import 'package:flutter_test/flutter_test.dart';
import '../../../../../fakes/fake_shares_repository.dart';
import 'package:social_app/core/data/models/my_model.dart';
import 'package:social_app/features/interactions/shares/domain/use_cases/get_shares_stream_use_case.dart';


void main() {
  late FakeSharesRepository fakeRepo;
  late GetSharesStreamUseCase useCase;

  setUp(() {
    fakeRepo = FakeSharesRepository();
    useCase = GetSharesStreamUseCase(repository: fakeRepo);
  });

  group('call', () {
    test('delegates to repository.getSharesStream with postId', () async {
      fakeRepo.sharesStream = Stream.value([]);

      await useCase
          .call('post-1')
          .first;

      expect(fakeRepo.getSharesStreamCallCount, 1);
      expect(fakeRepo.lastPostId, 'post-1');
    });

    test('returns stream from repository', () async {
      final model = MyModel(
        myId: 'uid-1',
        myDateTime: DateTime(2024, 5, 1),
      );

      fakeRepo.sharesStream = Stream.value([model]);

      final result = await useCase
          .call('post-1')
          .first;

      expect(result.length, 1);
      expect(result.first.myId, 'uid-1');
    });

    test('propagates errors from repository', () async {
      fakeRepo.sharesStream = Stream.error(Exception('stream failed'));

      expect(
            () =>
        useCase
            .call('post-1')
            .first,
        throwsA(isA<Exception>()),
      );
    });
  });
}