import 'package:flutter/material.dart';
import '../cubits/notifications_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../widgets/layouts/notifications_layout.dart';
import 'package:social_app/core/presentation/widgets/states/initial_state.dart';
import 'package:social_app/core/presentation/widgets/states/loading_state.dart';
import 'package:social_app/features/notifications/presentation/states/notifications_state.dart';


class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  late NotificationsCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = NotificationsCubit.get(context);
    _cubit.getNotifications();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NotificationsCubit, NotificationsState>(
        builder: (context, state) {
          return state.when(
              onInitial: () =>
                  InitialStateWidget(text: 'No notifications found',),
              onLoading: () => LoadingStateWidget(),
              onLoaded: (data) =>
                  SingleChildScrollView(
                      child: Column(
                        children: [
                          NotificationListBuilder(
                              notificationData: data.notificationsList),
                        ],
                      )
                  ),
              onError: (error) =>
                  error.buildErrorWidget(onRetry: () =>
                      _cubit.getNotifications()));
        }
    );
  }
}