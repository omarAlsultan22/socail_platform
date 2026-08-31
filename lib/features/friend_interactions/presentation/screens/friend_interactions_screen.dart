import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../states/friend_interactions_state.dart';
import '../../../../shared/componentes/public_components.dart';
import '../../../../core/presentation/states/app_sub_states.dart';
import 'package:social_app/core/presentation/widgets/states/initial_state.dart';
import 'package:social_app/core/presentation/widgets/states/loading_state.dart';
import 'package:social_app/features/friend_interactions/presentation/cubits/friend_interactions_cubit.dart';
import 'package:social_app/features/friend_interactions/presentation/widgets/layouts/friend_interactions_layout.dart';


class FriendInteractionsScreen extends StatefulWidget {
  const FriendInteractionsScreen({super.key});

  @override
  State<FriendInteractionsScreen> createState() => _FriendInteractionsScreenState();
}

class _FriendInteractionsScreenState extends State<FriendInteractionsScreen> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    FriendInteractionsCubit.get(context)
      ..getFriendsRequests()
      ..getFriendsSuggests();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<FriendInteractionsCubit, FriendInteractionsState>(
        listener: (context, state) {
          if(state is SuccessState) {
            if (state.stateKey == StatesKeys.confirmNewFriend) {
              ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content: Text('Your friend request has been approved'),
                      backgroundColor: Colors.green.shade700));
            }
            if (state.stateKey == StatesKeys.addFriendRequest) {
              ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content: Text('The request has been sent successfully'),
                      backgroundColor: Colors.green.shade700));
            }
            if (state.stateKey == StatesKeys.deleteFriendSuggest) {
              ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Deleted Successfully'),
                      backgroundColor: Colors.green.shade700));
            }
          }
        },
        builder: (context, state) {
          final cubit = FriendInteractionsCubit.get(context);
          final requests = cubit.friendsRequestsList;
          final suggests = cubit.friendsSuggestsList;
          return state.when(
              onInitial: ()=> InitialStateWidget(text: 'Type to start searching'),
              onLoading: ()=> LoadingStateWidget(),
              onLoaded: (loadedState)=> SingleChildScrollView(
                child: Column(
                  children: [
                    FriendInteractionsLayout(
                        notificationData: requests,
                        map: {
                          'title': 'Requests',
                          'AcceptButton': 'Confirm',
                          'RefuseButton': 'Decline',
                        },
                        acceptButton: (index) =>
                            cubit.confirmNewFriend(index: index, context: context),
                        refuseButton: (index) =>
                            cubit.declineFriendRequest(
                                index: index, context: context),
                        isActive: false
                    ),
                    sizedBox(),
                    FriendsLayout(
                        notificationData: suggests,
                        postStatuses: {
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
              ),
              onError: (error)=> error.buildErrorWidget()
          );
        }
    );
  }
}

