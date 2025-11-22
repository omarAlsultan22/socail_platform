import 'package:flutter/material.dart';
import 'cubit.dart';

class MainLayoutScreen extends StatelessWidget {
  final int currentScreen;

  const MainLayoutScreen({
    super.key,
    required this.currentScreen,
  });

  @override
  Widget build(BuildContext context) {
    final cubit = MainLayoutCubit.get(context);
    return cubit.mainScreens[currentScreen];
  }
}