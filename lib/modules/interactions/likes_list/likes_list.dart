import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_app/shared/cubit_states/cubit_states.dart';
import '../../../layout/interactions_layout/likes_layout/likes_layout.dart';
import '../../../shared/componentes/constants.dart';
import '../../../shared/componentes/public_components.dart';
import 'cubit.dart';

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
      child: BlocBuilder<LikesCubit, CubitStates>(
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
                          LikesCubit.get(context).insertFriendsRequests(
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