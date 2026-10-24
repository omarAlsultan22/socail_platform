import 'package:flutter/material.dart';
import '../../../../core/di/service _locator.dart';
import '../../../../core/domain/data_sources/local/cache_helper.dart';
import 'package:social_app/core/presentation/widgets/app_app_bar.dart';
import 'package:social_app/features/settings/presentation/widgets/layouts/settings_layout.dart';


class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: buildAppBar(title: 'Menu'),
        body: SettingsLayout(cacheHelper: sl<CacheHelper>()
        )
    );
  }
}