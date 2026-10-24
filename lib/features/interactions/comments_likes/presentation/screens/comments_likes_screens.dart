import 'package:flutter/material.dart';
import '../cubits/comments_likes_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/di/service _locator.dart';
import 'package:social_app/core/data/models/comment_model.dart';
import '../../../../../core/presentation/widgets/states/initial_state_widget.dart';
import '../../../../../core/presentation/widgets/states/loading_state_widget.dart';
import 'package:social_app/features/interactions/presentation/layouts/user_row_builder.dart';
import 'package:social_app/features/interactions/comments_likes/presentation/states/comments_likes_state.dart';


class CommentsLikesScreen extends StatelessWidget {
  final String userId;
  final CommentModel commentModel;

  const CommentsLikesScreen({
    super.key,
    required this.userId,
    required this.commentModel,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
        create: (context) =>
        sl<CommentsLikesCubit>()
          ..listenToLikes(commentModel),
        child: BlocBuilder<CommentsLikesCubit, CommentsLikesState>(
            builder: (context, state) {
              final cubit = CommentsLikesCubit.get(context);
              return state.when(
                  onInitial: () =>
                      InitialStateWidget(text: 'No comments likes found'),
                  onLoading: () => LoadingStateWidget(),
                  onLoaded: (data) =>
                      UserRowBuilder(
                          userId: userId,
                          userRowList: data.commentsLikesList
                      ),
                  onError: (failure) =>
                      failure.buildErrorWidget(
                          onRetry: () => cubit.listenToLikes(commentModel)
                      )
              );
            }
        )
    );
  }
}