import 'package:social_app/layout/interactions_layout/comments_layout.dart';

import 'cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';


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
        child: CommentsLayout(docId: docId, userId: userId!)
    );
  }
}