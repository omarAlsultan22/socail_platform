import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_app/modules/profile_screen/cubit.dart';
import 'package:social_app/shared/cubit_states/cubit_states.dart';
import '../../layout/home_layout/home_layout.dart';
import '../../shared/componentes/constants.dart';
import '../../shared/componentes/public_components.dart';
import 'cubit.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ScrollController _scrollControllerPosts = ScrollController();
  late HomeCubit _cubit;
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    _cubit = HomeCubit.get(context);
    _scrollControllerPosts.addListener(_onScrollPosts);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollControllerPosts.addListener(_onScrollPosts);
    });
  }

  void _onScrollPosts() {
    if (_isLoadingMore || !_cubit.hasMorePosts) return;

    final double scrollPosition = _scrollControllerPosts.position.pixels;
    final double maxScrollExtent = _scrollControllerPosts.position.maxScrollExtent;
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
    return BlocBuilder<HomeCubit, CubitStates>(
      builder: (context, state) {
        return SingleChildScrollView(
          controller: _scrollControllerPosts,
          scrollDirection: Axis.vertical,
          child: Column(
            children: [
              postInput(
                context: context,
              ),
              container(),
              HomeBuilder(
                homeStatus: _cubit.homeStatusList,
                homeData: _cubit.homeDataList,
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
                hasMoreStatus: _cubit.hasMoreStatus,
                hasMorePosts: _cubit.hasMorePosts,
                homeCubit: _cubit,
              )
            ],
          ),
        );
      },
    );
  }
}