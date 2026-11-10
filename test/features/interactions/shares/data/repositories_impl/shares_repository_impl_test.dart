import 'package:flutter_test/flutter_test.dart';
import 'package:social_app/core/data/models/my_model.dart';
import '../../../../../fakes/fake_shares_data_source.dart';
import 'package:social_app/features/interactions/shares/domain/repository/shares_repository.dart';
import 'package:social_app/features/interactions/shares/data/repository_impl/shares_repository_impl.dart';


void main() {
  late SharesRepository repository;
  late FakeSharesDataSource fakeDataSource;

  setUp(() {
    fakeDataSource = FakeSharesDataSource();
    repository = SharesRepositoryImpl(dataSource: fakeDataSource);
  });

  group('getSharesStream', () {
    test('delegates to dataSource.getSharesStream with postId', () async {
      fakeDataSource.sharesStream = Stream.value([]);

      await repository
          .getSharesStream('post-1')
          .first;

      expect(fakeDataSource.getSharesStreamCallCount, 1);
      expect(fakeDataSource.lastPostId, 'post-1');
    });

    test('returns stream from dataSource', () async {
      final model = MyModel(
        myId: 'uid-1',
        myDateTime: DateTime(2024, 5, 1),
      );

      fakeDataSource.sharesStream = Stream.value([model]);

      final result = await repository
          .getSharesStream('post-1')
          .first;

      expect(result.length, 1);
      expect(result.first.myId, 'uid-1');
    });

    test('propagates errors from dataSource', () async {
      fakeDataSource.sharesStream = Stream.error(Exception('stream failed'));

      expect(
            () =>
        repository
            .getSharesStream('post-1')
            .first,
        throwsA(isA<Exception>()),
      );
    });
  });
}