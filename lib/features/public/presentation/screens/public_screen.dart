import '../cubits/public_cubit.dart';
import 'package:flutter/material.dart';
import '../widgets/public_builder.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_app/shared/coordination/post_sync_groups.dart';
import 'package:social_app/shared/coordination/post_coordinator.dart';
import '../../../../core/presentation/widgets/states/initial_state.dart';
import 'package:social_app/features/public/data/models/user_details.dart';
import 'package:social_app/core/presentation/widgets/states/loading_state.dart';
import 'package:social_app/features/public/presentation/states/public_state.dart';
import 'package:social_app/core/presentation/widgets/create_post_input_widget.dart';


class PublicScreen extends StatefulWidget {
  const PublicScreen({super.key});

  @override
  State<PublicScreen> createState() => _PublicScreenState();
}

class _PublicScreenState extends State<PublicScreen> {
  late PublicCubit _cubit;
  final ScrollController _scrollControllerPosts = ScrollController();

  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    _cubit = PublicCubit.get(context);
    _scrollControllerPosts.addListener(_onScrollPosts);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollControllerPosts.addListener(_onScrollPosts);
    });
  }

  void _onScrollPosts() {
    if (_isLoadingMore || !_cubit.hasMorePosts) return;

    final double scrollPosition = _scrollControllerPosts.position.pixels;
    final double maxScrollExtent = _scrollControllerPosts.position
        .maxScrollExtent;
    final double scrollThreshold = maxScrollExtent * 0.8;

    if (scrollPosition >= scrollThreshold) {
      _loadMorePosts();
    }
  }

  Future<void> _loadMorePosts() async {
    if (_isLoadingMore) return;

    setState(() => _isLoadingMore = true);
    await _cubit.getHomePosts().whenComplete(() =>
        setState(() => _isLoadingMore = false)
    );
  }

  @override
  void dispose() {
    _scrollControllerPosts.removeListener(_onScrollPosts);
    _scrollControllerPosts.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PublicCubit, PublicState>(
      builder: (context, state) {
        return state.when(
          onInitial: () => const InitialStateWidget(),
          onLoading: () => const LoadingStateWidget(),
          onLoaded: (data) {
            UserDetails();
            return SingleChildScrollView(
              controller: _scrollControllerPosts,
              scrollDirection: Axis.vertical,
              child: Column(
                children: [
                  PostCreationWidget(
                    uId: data.currentUid,
                    messageResult: data.messageResult,
                    onUpsert: (postModel) =>
                        _cubit.upsertPostToRepository(
                            postModel: postModel),
                  ),
                  Container(
                    height: 1.0,
                    color: Colors.grey,
                  ),
                  PublicBuilder(
                    currentUid: data.currentUid,
                    homePosts: data.homePostsList,
                    hasMorePosts: data.hasMorePosts,
                    messageResult: data.messageResult,
                    homeStatuses: data.homeStatusesList,
                    hasMoreStatuses: data.hasMoreStatuses,
                    loadMoreStatus: () => _cubit.getHomeStatus(),
                    onUpdate: (userDetails) =>
                        _cubit.updateUserDetails(userDetails),
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
                    onUpsertStatus: (statusModel) async =>
                    await _cubit.upsertStatus(
                        statusModel: statusModel),
                    onRemoveStatus: (statusModel) async =>
                    await _cubit.removeStatus(statusModel: statusModel),
                    onUpsertPost: (postModel) async {
                      await _cubit.upsertPostToRepository(
                          postModel: postModel);
                      if (!context.mounted) return;
                      PostCoordinator.upsertPost(
                          context,
                          postModel: postModel,
                          group: PostSyncGroups.all
                      );
                    },
                    onRemovePost: (postModel) async {
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
                  )
                ],
              ),
            );
          },
          onError: (error) => error.buildErrorWidget(),
        );
      },
    );
  }
}