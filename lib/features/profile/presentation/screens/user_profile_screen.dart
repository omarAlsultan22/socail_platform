import '../states/profile_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../widgets/layouts/profile_layout.dart';
import '../../../../core/di/service _locator.dart';
import '../../../../core/services/data/session_service.dart';
import '../../../../core/services/domain/i_media_upload_service.dart';
import '../../../../core/presentation/widgets/states/initial_state.dart';
import '../../../../core/presentation/widgets/states/loading_state.dart';
import 'package:social_app/features/profile/presentation/cubits/user_profile_cubit.dart';


class UserProfileScreen extends StatelessWidget {
  final String friendId;

  const UserProfileScreen({
    required this.friendId,
    super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<UserProfileCubit>(
        create: (context) =>
        sl<UserProfileCubit>()
          ..getProfileInfo(uId: friendId)
          ..checkIsRequest(userId: friendId)
          ..checkIsFriend(userId: friendId),
        child: BlocBuilder<UserProfileCubit, ProfileState>(
            builder: (context, state) {
              final cubit = UserProfileCubit
                  .get(context);
              return state.when(
                onInitial: () =>
                const InitialStateWidget(text: 'User account does not exist.'),
                onLoading: () => const LoadingStateWidget(),
                onLoaded: (data) =>
                    Scaffold(
                      appBar: AppBar(
                        elevation: 0.0,
                        scrolledUnderElevation: 0.0,
                      ),
                      body: ProfileLayout(
                        uploadImage: (postModel) =>
                            cubit.uploadImage(postModel: postModel),
                        messageResult: data.messageResult,
                        sessionService: sl<SessionService>(),
                        deleteRequests: (userId) =>
                            cubit.cancelRequests(userId: userId),
                        deleteFriendship: (userId) =>
                            cubit.deleteFriendship(userId: userId),
                        userInfoModel: data.userInfoModel,
                        changeIndexButtons: (index) =>
                            cubit.changeIndexButtons(index),
                        insertFriendsRequests: (userId) =>
                            cubit.insertFriendsRequests(userId: userId),
                        currentButtonScreen: data.currentButtonScreen,
                        friendshipButtonKey: data.friendshipButtonKey,
                        mediaUploadService: sl<IMediaUploadService>(),
                        onAdd: (postModel) async =>
                        await cubit.addShare(
                            userId: postModel.myId,
                            postId: postModel.myDocId
                        ),
                        onToggle: (isActive, postModel) async =>
                        await cubit.toggleLike(
                            isActive: isActive,
                            postModel: postModel
                        ),
                        onUpsert: (postModel) async {
                          await cubit.upsertPostToRepository(
                              postModel: postModel);
                        },
                      ),
                    ),
                onError: (error) => error.buildErrorWidget(),
              );
            }
        )
    );
  }
}