import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:social_app/layout/menu_layout/update_info_layout.dart';
import 'package:social_app/shared/local/shared_preferences.dart';
import '../../main.dart';
import '../../shared/componentes/public_components.dart';
import '../sign_in/sign_in/sign_in.dart';
import '../../layout/menu_layout/update_account.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

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
                menuButton(
                  text: 'Account',
                  icon: Icons.account_circle,
                  onTap: () {
                    navigator(context, const UpdateAccount());
                  },
                ),
                const SizedBox(width: 20),
                menuButton(
                  text: 'Profile',
                  icon: Icons.info,
                  onTap: () {
                    navigator(context, const UpdateInfo());
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                menuButton(
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
                menuButton(
                  text: 'Exit',
                  icon: Icons.exit_to_app,
                  onTap: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => const SignIn()),
                          (Route<dynamic> route) => false,
                    );
                    CacheHelper.deleteStringValue(key: 'isLoggedIn');
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

Widget menuButton({
  required String text,
  required IconData icon,
  required VoidCallback onTap,
}) =>
    Expanded(
      child: Padding(
        padding: const EdgeInsets.all(0.0),
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
      ),
    );