import 'package:flutter_test/flutter_test.dart';
import '../../../../../fakes/fake_likes_data_source.dart';
import 'package:social_app/core/data/models/my_model.dart';
import 'package:social_app/features/interactions/likes/data/repository_impl/likes_repository_impl.dart';


void main() {
  late LikesRepositoryImpl repository;
  late FakeLikesDataSource fakeDataSource;

  setUp(() {
    fakeDataSource = FakeLikesDataSource();
    repository = LikesRepositoryImpl(dataSource: fakeDataSource);
  });

  group('getLikesStream', () {
    test('delegates to dataSource.getLikesStream with postId', () async {
      fakeDataSource.likesStream = Stream.value([]);

      await repository
          .getLikesStream('post-1')
          .first;

      expect(fakeDataSource.getLikesStreamCallCount, 1);
      expect(fakeDataSource.lastPostId, 'post-1');
    });

    test('returns stream from dataSource', () async {
      final model = MyModel(
        myId: 'uid-1',
        myDateTime: DateTime(2024, 5, 1),
      );

      fakeDataSource.likesStream = Stream.value([model]);

      final result = await repository
          .getLikesStream('post-1')
          .first;

      expect(result.length, 1);
      expect(result.first.myId, 'uid-1');
    });

    test('propagates errors from dataSource', () async {
      fakeDataSource.likesStream = Stream.error(Exception('stream failed'));

      expect(
            () =>
        repository
            .getLikesStream('post-1')
            .first,
        throwsA(isA<Exception>()),
      );
    });
  });
}