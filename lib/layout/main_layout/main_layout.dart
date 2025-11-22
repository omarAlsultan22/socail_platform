import 'package:flutter/material.dart';
import '../../modules/main_screen/cubit.dart';


class MainLayout extends StatelessWidget {
  final int currentScreen;

  const MainLayout({
    super.key,
    required this.currentScreen,
  });

  @override
  Widget build(BuildContext context) {
    final cubit = MainLayoutCubit.get(context);
    return cubit.mainScreens[currentScreen];
  }
}