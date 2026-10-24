import '../cubits/comments_cubit.dart';
import 'package:flutter/material.dart';
import '../layouts/comments_layout.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/di/service _locator.dart';
import 'package:social_app/core/presentation/widgets/states/initial_state_widget.dart';
import 'package:social_app/core/presentation/widgets/states/loading_state_widget.dart';
import 'package:social_app/features/interactions/comments/presentation/states/comments_state.dart';


class CommentsScreen extends StatelessWidget {
  final String docId;
  final String? userId;

  const CommentsScreen({
    super.key,
    this.userId,
    required this.docId,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
        create: (context) =>
        sl<CommentsCubit>()
          ..listenToComments(docId),
        child:
        BlocBuilder<CommentsCubit, CommentsState>(
            builder: (context, state) {
              final cubit = CommentsCubit.get(context);
              return state.when(
                  onInitial: () =>
                      InitialStateWidget(text: 'No comments found'),
                  onLoading: () => LoadingStateWidget(),
                  onLoaded: (data) =>
                      CommentsLayout(
                        userId: userId!,
                        onAdd: (commentText) =>
                            cubit.addComment(
                                postId: docId, comment: commentText),
                        onCheck: (value, commentModel) =>
                            cubit.chickLike(
                                isLike: value, comment: commentModel),
                        onRemove: (commentModel) =>
                            cubit.removeComment(comment: commentModel),
                        commentsList: data.commentsList,
                        messageResult: data.messageResult,
                      ),
                  onError: (failure) =>
                      failure.buildErrorWidget(
                          onRetry: () => cubit.listenToComments(docId)
                      )
              );
            }
        )
    );
  }
}