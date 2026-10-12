import 'package:social_app/core/data/models/my_model.dart';


abstract class CommentsLikesRepository {
  Stream<List<MyModel>> getCommentLikesStream({
    required String postId,
    required String commentId,
  });
}