import '../cubits/likes_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/di/service _locator.dart';
import '../../../../../core/presentation/widgets/states/initial_state.dart';
import '../../../../../core/presentation/widgets/states/loading_state.dart';
import 'package:social_app/features/interactions/likes/presentation/states/likes_state.dart';
import 'package:social_app/features/interactions/presentation/layouts/user_row_builder.dart';


class LikesScreen extends StatelessWidget {
  final String docId;
  final String? userId;

  const LikesScreen({
    super.key,
    this.userId,
    required this.docId,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
        create: (context) => sl<LikesCubit>()
          ..listenToLikes(docId),
        child: BlocBuilder<LikesCubit, LikesState>(
            builder: (context, state) {
              final cubit = LikesCubit.get(context);
              return state.when(
                  onInitial: () =>
                      InitialStateWidget(text: 'No likes found'),
                  onLoading: () => LoadingStateWidget(),
                  onLoaded: (data) =>
                      UserRowBuilder(
                          userId: userId,
                          userRowList: data.commentsLikesList
                      ),
                  onError: (failure) =>
                      failure.buildErrorWidget(
                          onRetry: () => cubit.listenToLikes(docId)
                      )
              );
            }
        )
    );
  }
}