import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_app/features/notifications/presentation/states/notifications_state.dart';
import '../../../../core/constants/user_details.dart';
import 'package:social_app/shared/cubit_states/cubit_states.dart';
import 'package:social_app/modules/notifications_screen/cubit.dart';
import 'package:social_app/features/notifications_screen/presentation/widgets/layouts/notifications_layout.dart';

import '../../cubit.dart';


class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    NotificationsCubit.get(context).getNotificationsRequests(userId: UserDetails.uId);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NotificationsCubit, NotificationsState>(
        builder: (context, state) {
          state.when(onInitial: onInitial, onLoading: onLoading, onLoaded: onLoaded, onError: onError)
          var notificationData = NotificationsCubit
              .get(context)
              .notificationsList;
          if(notificationData.isEmpty){
            return Center(child: CircularProgressIndicator());
          }
          return SingleChildScrollView(
              child: Column(
                children: [
                  NotificationListBuilder(notificationData: notificationData),
                ],
              )
          );
        }
    );
  }
}
