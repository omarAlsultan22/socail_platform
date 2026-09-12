import 'package:flutter/material.dart';
import '../cubits/setup_friends_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/service _locator.dart';
import '../widgets/layouts/setup_friends_layout.dart';
import 'package:social_app/core/data/data_sources/local/cache_helper.dart';
import 'package:social_app/core/presentation/widgets/states/initial_state.dart';
import 'package:social_app/core/presentation/widgets/states/loading_state.dart';
import 'package:social_app/features/setup_friends/presentation/states/setup_friends_state.dart';


class AddNewFriendsScreen extends StatelessWidget {
  final CacheHelper cacheHelper;

  const AddNewFriendsScreen({super.key, required this.cacheHelper});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(create: (context) =>
    sl<SetupFriendsCubit>()
      ..getSuggestsFriends(),
        child: BlocBuilder<SetupFriendsCubit, SetupFriendsState>(
            builder: (context, state) {
              final cubit = SetupFriendsCubit.get(context);
              return state.when(
                  onInitial: () =>
                      InitialStateWidget(text: 'No suggested friends found'),
                  onLoading: () => LoadingStateWidget(),
                  onLoaded: (data) =>
                      AddNewFriendsLayout(
                          onAdd: (friend) =>
                          cubit
                            ..addFriend(data.friendsNumber + 1)
                            ..confirmNewFriend(uId: friend.userId!),
                          onSave: () async =>
                          await cacheHelper.setBool(
                              key: 'friends', value: true),
                          friendsList: data.friendsList,
                          friendsNumber: data.friendsNumber,
                          messageResult: data.messageResult
                      ),
                  onError: (failure) =>
                      failure.buildErrorWidget(
                          onRetry: () => cubit.getSuggestsFriends()
                      )
              );
            }
        )
    );
  }
}

