import 'package:flutter/material.dart';
import '../cubits/post_detail_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../shared/coordination/post_coordinator.dart';
import '../../../../shared/coordination/post_sync_groups.dart';
import '../../../notifications/data/models/notification_model.dart';
import 'package:social_app/core/presentation/widgets/states/initial_state_widget.dart';
import 'package:social_app/core/presentation/widgets/states/loading_state_widget.dart';
import 'package:social_app/features/post_detail/presentation/states/post_detail_state.dart';
import 'package:social_app/features/post_detail/presentation/widgets/layouts/post_detail_layout.dart';


class PostDetailScreen extends StatefulWidget {
 final NotificationsModel notificationsModel;
  const PostDetailScreen({
    super.key,
    required this.notificationsModel,
  });

  @override
  State<PostDetailScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<PostDetailScreen> {
  late PostDetailCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = PostDetailCubit.get(context);
    _cubit.getPostData(
        userId: widget.notificationsModel.myId,
        postId: widget.notificationsModel.postId);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PostDetailCubit, PostDetailState>(
        builder: (context, state) {
          return state.when(
              onInitial: () =>
                  Scaffold(
                      body: Center(
                          child: InitialStateWidget(
                              text: 'The post does not exist.')
                      )
                  ),
              onLoading: () => Scaffold(body: LoadingStateWidget()),
              onLoaded: (data) =>
                  PostDetailLayout(
                    postModel: data.postModel,
                    commentsList: data.commentsList,
                    messageResult: data.messageResult,
                    getUId: (index) => data.getUserId(index),
                    notificationsModel: widget.notificationsModel,
                    getCommentModel: (index) => data.getCommentModel(index),
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
                      await _cubit.removePostFromRepository(
                          postModel: postModel);
                      if (!context.mounted) return;
                      PostCoordinator.removePost(
                          context,
                          postModel: postModel,
                          group: PostSyncGroups.all
                      );
                    },
                  ),
              onError: (error) =>
                  error.buildErrorWidget(onRetry: () =>
                      _cubit.getPostData(
                        userId: widget.notificationsModel.myId,
                        postId: widget.notificationsModel.postId,
                      )
                  )
          );
        }
    );
  }
}