import '../../../../main.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/layouts/update_account_layout.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../auth/presentation/screens/sign_in_screen.dart';
import '../../../../shared/networks/local/shared_preferences.dart';
import 'package:social_app/core/presentation/widgets/navigation/navigator.dart';
import 'package:social_app/features/menu/presentation/widgets/layouts/update_info_layout.dart';


class MenuScreen extends StatefulWidget {
  final CacheHelper cacheHelper;
  const MenuScreen({super.key, required this.cacheHelper});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  SharedPreferences? prefs;
  bool toggle = false;

  @override
  void initState() {
    super.initState();
    _initPrefs();
  }

  Future<void> _initPrefs() async {
    prefs = await SharedPreferences.getInstance();
    setState(() {
      toggle = prefs!.getString('theme') == 'light';
    });
  }

  Future<void> changeMode(bool toggle, BuildContext context) async {
    if (prefs == null) return;

    await prefs!.setString('theme', toggle ? 'light' : 'dark');
    final themeNotifier = Provider.of<ThemeNotifier>(context, listen: false);
    themeNotifier.setThemeMode(
      toggle ? ThemeMode.light : ThemeMode.dark,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Menu',
          style: TextStyle(
            fontSize: 30.0,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Center(
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
                        context: context, link: const UpdateAccount());
                  },
                ),
                const SizedBox(width: 20),
                MenuButton(
                  text: 'Profile',
                  icon: Icons.info,
                  onTap: () {
                    BuildNavigator.build(
                        context: context, link: const UpdateInfo());
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
                  onTap: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const SignInScreen()),
                          (Route<dynamic> route) => false,
                    );
                    CacheHelper.removeValue(key: 'isLoggedIn');
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}


class MenuButton extends StatelessWidget {
  final String text;
  final IconData icon;
  final VoidCallback onTap;

  const MenuButton({
    super.key,
    required this.text,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        height: 200.0,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.0),
          color: Colors.grey,
        ),
        child: InkWell(
          onTap: () => onTap(), // Call the function here
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: Colors.white,
                size: 50.0,
              ),
              Text(
                text,
                style: TextStyle(
                  fontSize: 15.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}