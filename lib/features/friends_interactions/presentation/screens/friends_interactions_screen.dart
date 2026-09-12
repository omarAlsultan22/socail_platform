import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_app/core/presentation/widgets/app_spaces.dart';
import '../states/friends_interactions_state.dart';
import '../widgets/layouts/friends_interactions_layout.dart';
import 'package:social_app/core/presentation/widgets/states/initial_state.dart';
import 'package:social_app/core/presentation/widgets/states/loading_state.dart';
import 'package:social_app/features/friends_interactions/presentation/cubits/friends_interactions_cubit.dart';


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
    FriendsInteractionsCubit.get(context)
      ..getFriendsRequests()
      ..getFriendsSuggests();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FriendsInteractionsCubit, FriendsInteractionsState>(
        builder: (context, state) {
          final cubit = FriendsInteractionsCubit.get(context);
          return state.when(
              onInitial: ()=> InitialStateWidget(),
              onLoading: ()=> LoadingStateWidget(),
              onLoaded: (data)=> SingleChildScrollView(
                child: Column(
                  children: [
                    FriendsInteractionsLayout(
                        notificationData: data.friendsRequestsList,
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
                    AppSpaces.vertical_16,
                    FriendsInteractionsLayout(
                        notificationData: data.friendsSuggestsList,
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
              ),
              onError: (error)=> error.buildErrorWidget()
          );
        }
    );
  }
}

