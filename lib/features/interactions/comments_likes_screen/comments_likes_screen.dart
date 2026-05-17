import 'cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_app/models/comment_model.dart';
import 'package:social_app/layout/interactions_layout/comments_likes_layout.dart';


class CommentsLikesScreen extends StatelessWidget {
  final CommentModel comment;
  final String? userId;

  const CommentsLikesScreen({
    this.userId,
    required this.comment,
    super.key
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
        create: (context) =>
        CommentsLikesCubit()
          ..listenToLikes(comment),
        child: CommentsLikesLayout(userId: userId!)
    );
  }
}