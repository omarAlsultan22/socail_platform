import '../states/profile_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/service _locator.dart';
import '../widgets/layouts/main_profile_layout.dart';
import '../../../../core/services/session_service.dart';
import '../../../../core/presentation/widgets/states/initial_state.dart';
import '../../../../core/presentation/widgets/states/loading_state.dart';
import 'package:social_app/features/profile/presentation/cubits/friend_profile_cubit.dart';


class FriendProfileScreen extends StatelessWidget {
  final String userId;

  const FriendProfileScreen({
    required this.userId,
    super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<FriendProfileCubit>(
        create: (context) =>
        sl<FriendProfileCubit>()
          ..getProfileInfo(uid: userId)
          ..getFriends(userId: userId)
          ..getProfileData(userId: userId)
          ..checkIsRequest(userId: userId)
          ..checkIsFriend(userId: userId),
        child: BlocBuilder<FriendProfileCubit, ProfileState>(
            builder: (context, state) {
              final cubit = FriendProfileCubit
                  .get(context);
              return state.when(
                onInitial: () => const InitialStateWidget(),
                onLoading: () => const LoadingStateWidget(),
                onLoaded: (data) {
                  return Scaffold(
                      appBar: AppBar(
                        elevation: 0.0,
                        scrolledUnderElevation: 0.0,
                      ),
                      body: MainProfileLayout(
                        uploadImage: (postModel) =>
                            cubit.uploadImage(postModel: postModel),
                        sessionService: sl<SessionService>(),
                        deleteRequests: (userId) =>
                            cubit.deleteRequests(userId: userId),
                        deleteFriendship: (userId) =>
                            cubit.deleteFriendship(userId: userId),
                        profileInfoModel: data.profileInfoModel,
                        changeIndexButtons: (index, userId) =>
                            cubit.changeIndexButtons(index, userId),
                        insertFriendsRequests: (userId) =>
                            cubit.insertFriendsRequests(userId: userId),
                      )
                  );
                },
                onError: (error) => error.buildErrorWidget(),
              );
            }
        )
    );
  }
}