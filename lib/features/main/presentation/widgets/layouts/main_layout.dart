import 'package:flutter/material.dart';
import '../../../../public/presentation/screens/public_screen.dart';
import '../../../../search/presentation/screens/search_screen.dart';
import '../../../../profile/presentation/screens/user_profile_screen.dart';
import '../../../../notifications/presentation/screens/notifications_screen.dart';
import 'package:social_app/features/settings/presentation/screens/settings_screen.dart';
import 'package:social_app/features/friendship/presentation/screens/friendship_screen.dart';


class MainLayout extends StatelessWidget {
  final int currentScreen;
  final int friendshipCount;
  final int notificationsCount;
  final TabController tabController;

  const MainLayout({
    super.key,
    required this.tabController,
    required this.currentScreen,
    required this.friendshipCount,
    required this.notificationsCount,
  });

  static const List<Widget> mainScreens = [
    PublicScreen(),
    NotificationsScreen(),
    FriendshipScreen(),
    UserProfileScreen(),
  ];

  Widget _buildTabIcon({
    int? count,
    required int index,
    required IconData activeIcon,
    required IconData inactiveIcon,
  }) {
    return Stack(
      children: [
        Tab(icon: Icon(
            tabController.index == index ? activeIcon : inactiveIcon)),
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
    return Scaffold(
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
                      builder: (context) => const SettingsScreen()
                  ),
                ),
            icon: const Icon(Icons.menu_outlined),
          ),
        ],
        bottom: TabBar(
          controller: tabController,
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
              count: notificationsCount,
            ),
            _buildTabIcon(
              index: 2,
              activeIcon: Icons.group,
              inactiveIcon: Icons.group_outlined,
              count: friendshipCount,
            ),
            _buildTabIcon(
              index: 3,
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
      body: mainScreens[currentScreen],
    );
  }
}