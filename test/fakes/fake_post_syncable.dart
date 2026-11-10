import 'package:social_app/core/data/models/post_model.dart';
import 'package:social_app/core/presentation/coordinators/post_syncable.dart';


class FakePostSyncable implements PostSyncable {
  int upsertCallCount = 0;
  int removeCallCount = 0;
  PostModel? lastUpsertPost;
  PostModel? lastRemovePost;

  @override
  void upsertPostToList(PostModel postModel) {
    upsertCallCount++;
    lastUpsertPost = postModel;
  }

  @override
  void removePostFromList(PostModel postModel) {
    removeCallCount++;
    lastRemovePost = postModel;
  }
}