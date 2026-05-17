import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../../modules/main_screen/cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../layout/main_layout/main_layout.dart';
import '../../modules/menu_screen/menu_screen.dart';
import '../../modules/search_screen/search_screen.dart';
import 'package:social_app/shared/cubit_states/cubit_states.dart';


class MainScreen extends StatefulWidget {
  final int? targetScreen;
  const MainScreen({this.targetScreen, super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  late MainLayoutCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = MainLayoutCubit.get(context);
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

  Widget _buildTabIcon(int index, IconData activeIcon, IconData inactiveIcon,
      {int? count, required MainLayoutCubit cubit}) {
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
    return BlocConsumer<MainLayoutCubit, CubitStates>(
      listener: (context, state) {
        if (_tabController.index != _cubit.currentScreen) {
          setState(() {
            _tabController.index = _cubit.currentScreen;
          });
        }
      },
      builder: (context, state) {
        return _buildMainLayout();
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
                        builder: (context) => const MenuScreen()),
                  ),
              icon: const Icon(Icons.menu_outlined),
            ),
          ],
          bottom: TabBar(
            controller: _tabController,
            tabs: [
              _buildTabIcon(
                0,
                Icons.public,
                Icons.public_outlined,
                cubit: _cubit,
              ),
              _buildTabIcon(
                1,
                Icons.notifications,
                Icons.notifications_outlined,
                count: _cubit.notificationsCount['counter'],
                cubit: _cubit,
              ),
              _buildTabIcon(
                2,
                Icons.group,
                Icons.group_outlined,
                count: _cubit.friendRequestsCount['counter'],
                cubit: _cubit,
              ),
              _buildTabIcon(
                3,
                CupertinoIcons.chat_bubble_2_fill,
                CupertinoIcons.chat_bubble_2,
                count: _cubit.messagesCount['counter'],
                cubit: _cubit,
              ),
              _buildTabIcon(
                4,
                Icons.home,
                Icons.home_outlined,
                cubit: _cubit,
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