import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_app/models/comment_model.dart';
import 'package:social_app/shared/cubit_states/cubit_states.dart';
import '../../../layout/interactions_layout/likes_layout/likes_layout.dart';
import '../../../shared/componentes/constants.dart';
import '../../../shared/componentes/public_components.dart';
import 'cubit.dart';

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
      child: BlocBuilder<CommentsLikesCubit, CubitStates>(
        builder: (context, state) {
          if (state is ListSuccessState) {
            return Scaffold(
              appBar: AppBar(
                scrolledUnderElevation: 0.0,
              ),
              body: ListBuilder(
                list: state.modelsList!,
                object: (like) =>
                    LikesModel(
                      like: like,
                      userId: userId,
                      onPressed: () =>
                          CommentsLikesCubit.get(context).insertFriendsRequests(
                            userId: UserDetails.uId,
                          ),
                    ),
                fallback: Center(
                  child: Text(
                    'There are no any likes',
                  ),
                ),
              ),
            );
          }
          return Scaffold(
            body: const Center(
              child: CircularProgressIndicator(),
            ),
          );
        },
      ),
    );
  }
}