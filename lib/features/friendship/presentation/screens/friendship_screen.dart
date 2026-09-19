import 'package:flutter/material.dart';
import '../cubits/friendship_cubit.dart';
import '../states/friendship_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../widgets/layouts/friendship_layout.dart';
import 'package:social_app/core/presentation/widgets/app_spaces.dart';
import 'package:social_app/core/presentation/widgets/states/initial_state.dart';
import 'package:social_app/core/presentation/widgets/states/loading_state.dart';
import 'package:social_app/features/friendship/domain/enums/friendship_type.dart';


class FriendshipScreen extends StatefulWidget {
  const FriendshipScreen({super.key});

  @override
  State<FriendshipScreen> createState() => _FriendshipScreenState();
}

class _FriendshipScreenState extends State<FriendshipScreen> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    FriendshipCubit.get(context)
      ..getFriendsRequests()
      ..getFriendsSuggests();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FriendshipCubit, FriendshipState>(
        builder: (context, state) {
          final cubit = FriendshipCubit.get(context);
          return state.when(
              onInitial: ()=> InitialStateWidget(),
              onLoading: ()=> LoadingStateWidget(),
              onLoaded: (data)=> SingleChildScrollView(
                child: Column(
                  children: [
                    FriendshipLayout(
                        notificationData: data.friendsRequestsList,
                        friendshipType: FriendshipType.request,
                        acceptButton: (index) =>
                            cubit.confirmNewFriend(index: index, context: context),
                        refuseButton: (index) =>
                            cubit.declineFriendRequest(
                                index: index, context: context),
                        isActive: false
                    ),
                    AppSpaces.vertical_16,
                    FriendshipLayout(
                        notificationData: data.friendsSuggestsList,
                        friendshipType: FriendshipType.suggestion,
                        acceptButton: (index) =>
                            cubit.addFriendSuggest(index: index),
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

