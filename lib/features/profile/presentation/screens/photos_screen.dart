import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../shared/coordination/post_coordinator.dart';
import '../../../../shared/coordination/post_sync_groups.dart';
import '../../../../core/presentation/widgets/states/initial_state_widget.dart';
import 'package:social_app/core/presentation/widgets/states/loading_state_widget.dart';
import 'package:social_app/features/profile/presentation/cubits/photos_cubit.dart';
import 'package:social_app/features/profile/presentation/states/photos_state.dart';
import 'package:social_app/features/profile/presentation/widgets/layouts/photos_layout.dart';


class PhotosScreen extends StatefulWidget {
  final String uId;
  const PhotosScreen({
    super.key,
    required this.uId
  });

  @override
  State<PhotosScreen> createState() => _PhotosScreenState();
}

class _PhotosScreenState extends State<PhotosScreen> {
  late PhotosCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = PhotosCubit.get(context);
    _cubit
      ..setUserId(widget.uId)
      ..getProfilePhotos(userId: widget.uId);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PhotosCubit, PhotosState>(
        builder: (context, state) {
          return state.when(
            onInitial: () =>
            const InitialStateWidget(text: 'No images available'),
            onLoading: () => const LoadingStateWidget(),
            onLoaded: (data) =>
                PhotosLayout(
                  currentIndex: data.currentIndex,
                  messageResult: data.messageResult,
                  listenerScreens: data.listenerScreens,
                  paginatedPostsMap: data.paginatedPostsMap,
                  changeIndex: (index) => _cubit.changeIndex(index),
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
                        group: PostSyncGroups.photo
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
                        group: PostSyncGroups.photo
                    );
                  },
                ),
            onError: (error) =>
                error.buildErrorWidget(
                    onRetry: () => _cubit.getProfilePhotos(userId: widget.uId)
                ),
          );
        }
    );
  }
}
