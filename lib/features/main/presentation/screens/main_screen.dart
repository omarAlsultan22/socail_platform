import '../cubits/main_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../widgets/layouts/main_layout.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/service _locator.dart';
import '../../../search/presentation/screens/search_screen.dart';
import 'package:social_app/core/data/data_sources/local/cache_helper.dart';
import 'package:social_app/features/main/presentation/states/main_state.dart';


class MainScreen extends StatefulWidget {
  final int? targetScreen;
  const MainScreen({this.targetScreen, super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  late MainCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = MainCubit.get(context);
    _cubit.currentScreen = widget.targetScreen ?? 0;
    _tabController = TabController(length: 5, vsync: this);
    _tabController.addListener(_handleTabSelection);
  }

  void _handleTabSelection() {
    if (_tabController.indexIsChanging) {
      _cubit.changeIndexScreen(_tabController.index);
    }
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabSelection);
    _tabController.dispose();
    super.dispose();
  }

  Widget _buildTabIcon({
    int? count,
    required int index,
    required IconData activeIcon,
    required IconData inactiveIcon,
  }) {
    return Stack(
      children: [
        Tab(icon: Icon(
            _tabController.index == index ? activeIcon : inactiveIcon)),
        if (count != null && count > 0)
          Positioned(
            top: 0,
            right: 0,
            child: CircleAvatar(
              radius: 8,
              backgroundColor: Colors.red,
              child: Text(
                count.toString(),
                style: const TextStyle(fontSize: 10),
              ),
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<MainCubit, MainState>(
      listener: (context, state) {
        if (_tabController.index != _cubit.currentScreen) {
          setState(() {
            _tabController.index = _cubit.currentScreen;
          });
        }
      },
      builder: (context, state) {
        return state.when(
            onInitial: onInitial,
            onLoading: onLoading,
            onLoaded: (data)=> _buildMainLayout(),
            onError: onError
        );
      },
    );
  }

  Widget _buildMainLayout() =>
      Scaffold(
        appBar: AppBar(
          elevation: 0.0,
          scrolledUnderElevation: 0.0,
          title: Row(
            children: [
              const Text(
                'Social',
                style: TextStyle(
                  fontSize: 30.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 10.0),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5.0),
                  color: Theme
                      .of(context)
                      .brightness == Brightness.light
                      ? Colors.black
                      : Colors.white,
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 0.9,
                    horizontal: 5.0,
                  ),
                  child: Text(
                    'Platform',
                    style: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                      color: Theme
                          .of(context)
                          .brightness == Brightness.light
                          ? Colors.white
                          : Colors.black,
                    ),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            IconButton(
              onPressed: () =>
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const SearchScreen()),
                  ),
              icon: const Icon(Icons.search, size: 30.0),
            ),
            IconButton(
              onPressed: () =>
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => MenuScreen(cacheHelper: sl<CacheHelper>()
                        )
                    ),
                  ),
              icon: const Icon(Icons.menu_outlined),
            ),
          ],
          bottom: TabBar(
            controller: _tabController,
            tabs: [
              _buildTabIcon(
                index: 0,
                activeIcon: Icons.public,
                inactiveIcon: Icons.public_outlined,
              ),
              _buildTabIcon(
                index: 1,
                activeIcon: Icons.notifications,
                inactiveIcon: Icons.notifications_outlined,
                count: _cubit.notificationsCount['counter'],
              ),
              _buildTabIcon(
                index: 2,
                activeIcon: Icons.group,
                inactiveIcon: Icons.group_outlined,
                count: _cubit.friendRequestsCount['counter'],
              ),
              _buildTabIcon(
                index: 3,
                activeIcon: CupertinoIcons.chat_bubble_2_fill,
                inactiveIcon: CupertinoIcons.chat_bubble_2,
                count: _cubit.messagesCount['counter'],
              ),
              _buildTabIcon(
                index: 4,
                activeIcon: Icons.home,
                inactiveIcon:  Icons.home_outlined,
              ),
            ],
            indicatorSize: TabBarIndicatorSize.tab,
            labelStyle: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
            unselectedLabelStyle: const TextStyle(fontSize: 12),
            splashBorderRadius: BorderRadius.circular(10.0),
          ),
        ),
        body: MainLayout(currentScreen: _cubit.currentScreen),
      );
}