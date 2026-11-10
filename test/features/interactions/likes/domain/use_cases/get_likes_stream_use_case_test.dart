import 'package:flutter_test/flutter_test.dart';
import '../../../../../fakes/fake_likes_repository.dart';
import 'package:social_app/core/data/models/my_model.dart';
import 'package:social_app/features/interactions/likes/domain/use_cases/get_likes_stream_use_case.dart';


void main() {
  late FakeLikesRepository fakeRepo;
  late GetLikesStreamUseCase useCase;

  setUp(() {
    fakeRepo = FakeLikesRepository();
    useCase = GetLikesStreamUseCase(repository: fakeRepo);
  });

  group('call', () {
    test('delegates to repository.getLikesStream with postId', () async {
      fakeRepo.likesStream = Stream.value([]);

      await useCase.call('post-1').first;

      expect(fakeRepo.getLikesStreamCallCount, 1);
      expect(fakeRepo.lastPostId, 'post-1');
    });

    test('returns stream from repository', () async {
      final model = MyModel(
        myId: 'uid-1',
        myDateTime: DateTime(2024, 5, 1),
      );

      fakeRepo.likesStream = Stream.value([model]);

      final result = await useCase.call('post-1').first;

      expect(result.length, 1);
      expect(result.first.myId, 'uid-1');
    });

    test('propagates errors from repository', () async {
      fakeRepo.likesStream = Stream.error(Exception('stream failed'));

      expect(
            () => useCase.call('post-1').first,
        throwsA(isA<Exception>()),
      );
    });
  });
}