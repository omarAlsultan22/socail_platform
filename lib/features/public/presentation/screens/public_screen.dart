import '../widgets/public_builder.dart';
import '../cubits/public_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/service _locator.dart';
import '../../../../core/services/session_service.dart';
import 'package:social_app/features/profile/cubit.dart';
import '../../../../core/presentation/widgets/states/initial_state.dart';
import 'package:social_app/core/presentation/widgets/states/loading_state.dart';
import 'package:social_app/features/public/presentation/states/public_state.dart';
import 'package:social_app/features/public/presentation/widgets/create_post_input_widget.dart';


class PublicScreen extends StatefulWidget {
  const PublicScreen({super.key});

  @override
  State<PublicScreen> createState() => _PublicScreenState();
}

class _PublicScreenState extends State<PublicScreen> {
  final ScrollController _scrollControllerPosts = ScrollController();
  late PublicCubit _publicCubit;
  late ProfileCubit _profileCubit;
  late SessionService _sessionService;

  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    _sessionService = sl<SessionService>();
    _publicCubit = PublicCubit.get(context);
    _profileCubit = ProfileCubit.get(context);
    _scrollControllerPosts.addListener(_onScrollPosts);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollControllerPosts.addListener(_onScrollPosts);
    });
  }

  void _onScrollPosts() {
    if (_isLoadingMore || !_publicCubit.hasMorePosts) return;

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
    await _publicCubit.getHomePosts().whenComplete(() =>
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
            return SingleChildScrollView(
              controller: _scrollControllerPosts,
              scrollDirection: Axis.vertical,
              child: Column(
                children: [
                  PostCreationWidget(
                      userImage: data.userImage,
                      insertAndUpdatePublicPosts: (postModel) =>
                          _publicCubit.insertAndUpdatePosts(
                              postModel: postModel),
                      insertAndUpdateProfilePosts: (postModel) =>
                          _profileCubit.insertAndUpdatePosts(postModel:
                          postModel)
                  ),
                  Container(
                    height: 1.0,
                    color: Colors.grey,
                  ),
                  PublicBuilder(
                    userImage: data.userImage,
                    homeStatuses: data.homeStatusesList,
                    sessionService: _sessionService,
                    homePosts: data.homePostsList,
                    hasMorePosts: data.hasMorePosts,
                    hasMoreStatuses: data.hasMoreStatuses,
                    loadMoreStatus: () => _publicCubit.getHomeStatus(),
                    insertAndUpdateStatuses: (statusModel) =>
                        _publicCubit.insertAndUpdateStatuses(
                            statusModel: statusModel),
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