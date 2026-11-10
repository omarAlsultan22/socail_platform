import 'package:social_app/core/data/models/my_model.dart';
import 'package:social_app/features/interactions/shares/domain/repository/shares_repository.dart';


class FakeSharesRepository implements SharesRepository {
  Stream<List<MyModel>>? sharesStream;
  int getSharesStreamCallCount = 0;
  String? lastPostId;

  @override
  Stream<List<MyModel>> getSharesStream(String postId) {
    getSharesStreamCallCount++;
    lastPostId = postId;
    return sharesStream!;
  }
}