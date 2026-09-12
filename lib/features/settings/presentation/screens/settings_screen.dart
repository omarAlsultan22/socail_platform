import 'package:flutter/material.dart';
import '../../../../core/di/service _locator.dart';
import '../../../../core/data/data_sources/local/cache_helper.dart';
import 'package:social_app/features/settings/presentation/widgets/layouts/settings_layout.dart';


class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

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
        body: SettingsLayout(cacheHelper: sl<CacheHelper>()
        )
    );
  }
}
