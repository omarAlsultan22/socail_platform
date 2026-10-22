import 'package:social_app/core/data/models/my_model.dart';
import '../../domain/repository/comments_likes_repository.dart';
import '../../domain/data_sources/comments_likes_data_source.dart';


class CommentsLikesRepositoryImpl implements CommentsLikesRepository {
  final CommentsLikesDataSource _dataSource;

  CommentsLikesRepositoryImpl({
    required CommentsLikesDataSource dataSource}) :
        _dataSource = dataSource;

  @override
  Stream<List<MyModel>> getCommentLikesStream({
    required String postId,
    required String commentId,
  }) {
    return _dataSource
        .getCommentLikesStream(postId: postId, commentId: commentId)
        .map(
          (users) =>
          users
              .map((u) =>
              MyModel(
                myId: u.myId,
                myDateTime: u.myDateTime,
              ))
              .toList(),
    );
  }
}