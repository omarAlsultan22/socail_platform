import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/presentation/widgets/app_spaces.dart';
import '../../../../shared/coordination/post_coordinator.dart';
import '../../../../shared/coordination/post_sync_groups.dart';
import 'package:social_app/core/presentation/widgets/states/loading_state.dart';
import 'package:social_app/features/profile/presentation/cubits/videos_cubit.dart';
import 'package:social_app/features/profile/presentation/states/videos_state.dart';
import 'package:social_app/features/profile/presentation/widgets/layouts/videos_layout.dart';


class VideosScreen extends StatefulWidget {
  final String uId;
  const VideosScreen({
    super.key,
    required this.uId
  });

  @override
  State<VideosScreen> createState() => _VideosScreenState();
}

class _VideosScreenState extends State<VideosScreen> {
  late VideosCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = VideosCubit.get(context);
    _cubit.getVideosPosts(userId: widget.uId);
  }

  Widget _initialStateWidget() {
    return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              AppSpaces.vertical_16,
              Text("My videos",
                style: TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold
                ),
              ),
              AppSpaces.vertical_16,
              Text('There is no any videos here',
                style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.normal
                ),
              ),
            ],
          )
        ]
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<VideosCubit, VideosState>(
        builder: (context, state) {
          return state.when(
            onInitial: _initialStateWidget,
            onLoading: () => const LoadingStateWidget(),
            onLoaded: (data) =>
                VideosLayout(
                  videosList: data.videosList,
                  hasMoreVideos: data.hasMoreVideos,
                  messageResult: data.messageResult,
                  onScroll: () => _cubit.loadMoreVideos(widget.uId),
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
                        group: PostSyncGroups.video
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
                        group: PostSyncGroups.video
                    );
                  },
                ),
            onError: (error) =>
                error.buildErrorWidget(
                    onRetry: () => _cubit.getVideosPosts(userId: widget.uId)
                ),
          );
        }
    );
  }
}
