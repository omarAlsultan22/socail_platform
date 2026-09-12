import 'package:flutter/material.dart';
import '../../../../../core/di/service _locator.dart';
import '../../../../public/presentation/screens/public_screen.dart';
import '../../../../search/presentation/screens/search_screen.dart';
import '../../../../profile/presentation/screens/my_profile_screen.dart';
import 'package:social_app/core/presentation/widgets/navigation/navigator.dart';
import '../../../../notifications/presentation/screens/notifications_screen.dart';
import 'package:social_app/features/settings/presentation/screens/settings_screen.dart';
import '../../../../friends_interactions/presentation/screens/friends_interactions_screen.dart';


class MainLayout extends StatelessWidget {
  final int currentScreen;

  const MainLayout({
    super.key,
    required this.currentScreen,
  });

  static const List<Widget> mainScreens = [
    HomeScreen(),
    NotificationsScreen(),
    FriendInteractionsScreen(),
    ChatScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
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
    BuildNavigator.build(context: context, link:  const SettingsScreen()),
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
      body: mainScreens[currentScreen],
    );
  }
}