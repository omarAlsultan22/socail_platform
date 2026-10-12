import 'package:social_app/core/data/models/my_model.dart';
import '../datasources/comments_likes_remote_datasource.dart';
import '../../domain/repository/comments_likes_repository.dart';


class CommentsLikesRepositoryImpl implements CommentsLikesRepository {
  final CommentsLikesRemoteDataSource remoteDataSource;

  CommentsLikesRepositoryImpl({required this.remoteDataSource});

  @override
  Stream<List<MyModel>> getCommentLikesStream({
    required String postId,
    required String commentId,
  }) {
    return remoteDataSource
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