import '../../data/models/post_model.dart';


abstract class PostSyncable{
  void upsertPostToList(PostModel post);
  void removePostFromList(PostModel post);
}