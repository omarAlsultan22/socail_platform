import 'package:social_app/core/data/models/my_model.dart';
import 'package:social_app/core/data/data_sources/remote/firestore/firestore_service_impl.dart';
import 'package:social_app/features/interactions/likes/domain/data_sources/likes_data_source.dart';


class FakeLikesDataSource extends FirestoreServiceImpl implements LikesDataSource {
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