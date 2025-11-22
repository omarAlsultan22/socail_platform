import 'cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../shared/componentes/public_components.dart';
import 'package:social_app/shared/cubit_states/cubit_states.dart';
import '../../../layout/interactions_layout/commetns_layout/comments_layout.dart';


class CommentsScreen extends StatelessWidget {
  final String docId;
  final String? userId;

  const CommentsScreen({
    this.userId,
    required this.docId,
    super.key
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
      CommentsCubit()
        ..listenToComments(docId),
      child: BlocBuilder<CommentsCubit, CubitStates>(
        builder: (context, state) {
          final cubit = CommentsCubit.get(context);
          if (state is SuccessState) {
            return Scaffold(
              appBar: AppBar(
                scrolledUnderElevation: 0.0,
              ),
              body: Column(
                children: [
                  Expanded(
                    child: ListBuilder(
                      list: state.modelsList!,
                      object: (comment) =>
                          CommentsModel(
                            userId: userId,
                            comment: comment,
                            onTap: (value) =>
                                cubit.chickLike(
                                    isLike: value, comment: comment),
                            onLongPressed: (value) =>
                                cubit.deleteComment(comment: comment),
                          ),
                      fallback: Text('There are no any comments'),
                    ),
                  ),
                  CommentForm(onPressed: (comment) =>
                      cubit.addComment(postId: docId, comment: comment))
                ],
              ),
            );
          }
          return Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              )
          );
        },
      ),
    );
  }
}