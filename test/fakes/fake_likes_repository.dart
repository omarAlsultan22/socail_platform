import 'package:social_app/core/data/models/my_model.dart';
import 'package:social_app/features/interactions/likes/domain/repository/likes_repository.dart';


class FakeLikesRepository implements LikesRepository {
  Stream<List<MyModel>>? likesStream;
  int getLikesStreamCallCount = 0;
  String? lastPostId;

  @override
  Stream<List<MyModel>> getLikesStream(String postId) {
    getLikesStreamCallCount++;
    lastPostId = postId;
    return likesStream!;
  }
}