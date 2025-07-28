import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_app/modules/friends_screen/cubit.dart';
import '../../layout/friends_layout/friends_layout.dart';
import '../../shared/componentes/public_components.dart';
import '../../shared/cubit_states/cubit_states.dart';

class FriendsScreen extends StatefulWidget {
  const FriendsScreen({super.key,});

  @override
  State<FriendsScreen> createState() => _FriendsScreenState();
}

class _FriendsScreenState extends State<FriendsScreen> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    FriendsCubit.get(context)
      ..getFriendsRequests()
      ..getFriendsSuggests();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<FriendsCubit, CubitStates>(
        listener: (context, state) {
          if (state is RequestSuccessState) {
            ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Your friend request has been approved'), backgroundColor: Colors.green.shade700));
          }
          if (state is SuggestSuccessState) {
            ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('The request has been sent successfully'), backgroundColor: Colors.green.shade700));
          }
          if (state is DeleteSuccessState) {
            ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Deleted Successfully'), backgroundColor: Colors.green.shade700));
          }

        },
        builder: (context, state) {
          final cubit = FriendsCubit.get(context);
          final requests = cubit.friendsRequestsList;
          final suggests = cubit.friendsSuggestsList;
          return SingleChildScrollView(
            child: Column(
              children: [
                buildFriendListSection(
                    notificationData: requests,
                    map: {
                      'title': 'Requests',
                      'AcceptButton': 'Confirm',
                      'RefuseButton': 'Decline',
                    },
                    acceptButton: (index) =>
                        cubit.confirmNewFriend(index: index, context: context),
                    refuseButton: (index) =>
                        cubit.declineFriendRequest(index: index, context: context),
                    isActive: false
                ),
                sizedBox(),
                buildFriendListSection(
                    notificationData: suggests,
                    map: {
                      'title': 'Suggests',
                      'AcceptButton': 'Add Friend',
                      'RefuseButton': 'Delete',
                    },
                    acceptButton: (index) =>
                        cubit.addFriendRequest(index: index),
                    refuseButton: (index) =>
                        cubit.deleteFriendSuggest(index: index),
                    isActive: true
                ),
              ],
            ),
          );
        }
    );
  }
}

