import 'package:social_app/layout/interactions_layout/likes_layout.dart';

import 'cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';


class LikesScreen extends StatelessWidget {
  final String docId;
  final String? userId;

  const LikesScreen({
    this.userId,
    required this.docId,
    super.key
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
        create: (context) =>
        LikesCubit()
          ..listenToLikes(docId),
        child: LikesLayout(userId: userId ?? '')
    );
  }
}