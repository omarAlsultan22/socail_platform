import '../menu_button.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../../core/themes/theme_notifier.dart';
import '../../../../auth/presentation/screens/sign_in_screen.dart';
import '../../../../../core/data/data_sources/local/cache_helper.dart';
import '../../../../user_account/presentation/screens/user_account_screen.dart';
import 'package:social_app/core/presentation/widgets/navigation/navigator.dart';
import 'package:social_app/features/user_info/presentation/screens/user_info_screen.dart';
import 'package:social_app/core/presentation/widgets/navigation/navigator_with_delay.dart';


class SettingsLayout extends StatefulWidget {
  final CacheHelper cacheHelper;
  const SettingsLayout({super.key, required this.cacheHelper});

  @override
  State<SettingsLayout> createState() => _SettingsLayoutState();
}

class _SettingsLayoutState extends State<SettingsLayout> {
  bool toggle = false;

  @override
  void initState() {
    super.initState();
    _initPrefs();
  }

  Future<void> _initPrefs() async {
    setState(() async {
      toggle = await widget.cacheHelper.getString(key: 'theme') == 'light';
    });
  }

  Future<void> changeMode(bool toggle, BuildContext context) async {
    await widget.cacheHelper.setString(
        key: 'theme', value: toggle ? 'light' : 'dark');
    final themeNotifier = Provider.of<ThemeNotifier>(context, listen: false);
    themeNotifier.setTheme(
      toggle ? ThemeMode.light : ThemeMode.dark,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              MenuButton(
                text: 'Account',
                icon: Icons.account_circle,
                onTap: () {
                  BuildNavigator.build(
                      context: context, link: const UserAccountScreen());
                },
              ),
              const SizedBox(width: 20),
              MenuButton(
                text: 'Profile',
                icon: Icons.info,
                onTap: () {
                  BuildNavigator.build(
                      context: context, link: const UserInfoScreen());
                },
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              MenuButton(
                text: 'Mode',
                icon: toggle ? Icons.wb_sunny_outlined : Icons
                    .nightlight_round,
                onTap: () async {
                  setState(() {
                    toggle = !toggle;
                  });
                  await changeMode(toggle, context);
                },
              ),
              const SizedBox(width: 20),
              MenuButton(
                text: 'Exit',
                icon: Icons.exit_to_app,
                onTap: () async {
                  await widget.cacheHelper.removeValue(key: 'isLoggedIn');
                  NavigatorWithDelay.build(
                      context: context, link: const SignInScreen());
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
