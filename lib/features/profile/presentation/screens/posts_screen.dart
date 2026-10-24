import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/service _locator.dart';
import '../../../../shared/coordination/post_coordinator.dart';
import '../../../../shared/coordination/post_sync_groups.dart';
import 'package:social_app/core/services/data/session_service.dart';
import '../../../../core/presentation/widgets/states/initial_state_widget.dart';
import 'package:social_app/core/presentation/widgets/states/loading_state_widget.dart';
import 'package:social_app/features/profile/presentation/cubits/posts_cubit.dart';
import 'package:social_app/features/profile/presentation/states/posts_state.dart';
import 'package:social_app/features/profile/presentation/widgets/layouts/posts_layout.dart';


class PostsScreen extends StatefulWidget {
  final String uId;
  const PostsScreen({
    super.key,
    required this.uId,
  });

  @override
  State<PostsScreen> createState() => _PostsScreenState();
}

class _PostsScreenState extends State<PostsScreen> {
  late PostsCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = PostsCubit.get(context);
    _cubit.getPostsData(userId: widget.uId);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PostsCubit, PostsState>(
        builder: (context, state) {
          return state.when(
            onInitial: () => const InitialStateWidget(text: 'No posts found'),
            onLoading: () => const LoadingStateWidget(),
            onLoaded: (data) =>
                PostsLayout(
                  userId: widget.uId,
                  postsList: data.postsList,
                  profileInfo: data.profileInfo,
                  friendsList: data.friendsList,
                  hasMorePosts: data.hasMorePosts,
                  messageResult: data.messageResult,
                  sessionService: sl<SessionService>(),
                  onScroll: () => _cubit.loadMorePosts(widget.uId),
                  onAdd: (postModel) async =>
                  await _cubit.addShare(
                      userId: postModel.myId,
                      postId: postModel.myDocId
                  ),
                  onToggle: (isActive, postModel) async =>
                  await _cubit.toggleLike(
                      isActive: isActive,
                      postModel: postModel
                  ),
                  onUpsert: (postModel) async {
                    await _cubit.upsertPostToRepository(postModel: postModel);
                    if (!context.mounted) return;
                    PostCoordinator.upsertPost(
                        context,
                        postModel: postModel,
                        group: PostSyncGroups.all
                    );
                  },
                  onRemove: (postModel) async {
                    if (postModel.postIsShared) {
                      await _cubit.removeShare(
                          userId: postModel.myId,
                          postId: postModel.myDocId
                      );
                    }
                    await _cubit.removePostFromRepository(postModel: postModel);
                    if (!context.mounted) return;
                    PostCoordinator.removePost(
                        context,
                        postModel: postModel,
                        group: PostSyncGroups.all
                    );
                  },
                ),
            onError: (error) =>
                error.buildErrorWidget(
                    onRetry: () => _cubit.getPostsData(userId: widget.uId)
                ),
          );
        }
    );
  }
}
