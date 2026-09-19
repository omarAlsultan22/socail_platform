import '../cubits/main_cubit.dart';
import 'package:flutter/material.dart';
import '../widgets/layouts/main_layout.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_app/features/main/presentation/states/main_state.dart';


class MainScreen extends StatefulWidget {
  final int? targetScreen;
  const MainScreen({this.targetScreen, super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with TickerProviderStateMixin {
  late final TabController _tabController;
  late final MainCubit _cubit;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(_onTabChanged);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _cubit = MainCubit.get(context);
  }

  void _onTabChanged() {
    if (!_tabController.indexIsChanging) return;
    _cubit.changeIndexScreen(_tabController.index);
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<MainCubit, MainState>(
      listenWhen: (prev, curr) => prev.currentScreen != curr.currentScreen,
      listener: (context, state) {
        if (_tabController.index != state.currentScreen) {
          _tabController.animateTo(state.currentScreen);
        }
      },
      builder: (context, state) => MainLayout(
        tabController: _tabController,
        currentScreen: state.currentScreen,
        friendshipCount: state.friendshipCount,
        notificationsCount: state.notificationsCount,
      ),
    );
  }
}