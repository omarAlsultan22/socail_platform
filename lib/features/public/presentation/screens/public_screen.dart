import '../../cubit.dart';
import '../cubits/public_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/user_details.dart';
import '../../../../shared/componentes/public_components.dart';
import '../widgets/layouts/public_layout.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ScrollController _scrollControllerPosts = ScrollController();
  late PublicCubit _cubit;
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
    return BlocBuilder<PublicCubit, CubitStates>(
      builder: (context, state) {
        return SingleChildScrollView(
          controller: _scrollControllerPosts,
          scrollDirection: Axis.vertical,
          child: Column(
            children: [
              PostInput(
                context: context,
              ),

              Container(
                height: 1.0,
                color: Colors.grey,
              ),
              HomeBuilder(
                homeStatus: _cubit.homeStatusesList,
                homeData: _cubit.homePostsList,
                deletePost: (postModel) {
                  if (postModel.userId == UserDetails.uId) {
                    ProfileCubit.get(context).deletePost(postModel: postModel);
                  }
                  _cubit.deletePost(postModel: postModel);
                },
                deleteStatus: (statusModel) {
                  _cubit.deleteStatus(
                      statusModel: statusModel);
                },
                loadMoreStatus: () => _cubit.getHomeStatus(),
                hasMoreStatuses: _cubit.hasMoreStatuses,
                hasMorePosts: _cubit.hasMorePosts,
                homeCubit: _cubit, hasMoreStatuses: null,
              )
            ],
          ),
        );
      },
    );
  }
}