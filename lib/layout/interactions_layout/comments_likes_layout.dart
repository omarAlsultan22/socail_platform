import 'like_model_layout.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../shared/constants/user_details.dart';
import '../../shared/cubit_states/cubit_states.dart';
import '../../modules/interactions/comments_likes_screen/cubit.dart';
import 'package:social_app/shared/componentes/public_components.dart';


class CommentsLikesLayout extends StatelessWidget {
  final String userId;
  const CommentsLikesLayout({required this.userId, super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CommentsLikesCubit, CubitStates>(
      builder: (context, state) {
        if (state is SuccessState) {
          return Scaffold(
            appBar: AppBar(
              scrolledUnderElevation: 0.0,
            ),
            body: ListBuilder(
              list: state.modelsList!,
              object: (like) =>
                  LikeModelLayout(
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
    );
  }
}
