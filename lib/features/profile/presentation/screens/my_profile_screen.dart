import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../widgets/layouts/profile_layout.dart';
import '../../../../core/di/service _locator.dart';
import '../../../../shared/coordination/post_coordinator.dart';
import '../../../../shared/coordination/post_sync_groups.dart';
import 'package:social_app/core/services/session_service.dart';
import '../../../../core/presentation/widgets/states/initial_state.dart';
import 'package:social_app/core/presentation/widgets/states/loading_state.dart';
import 'package:social_app/features/profile/presentation/states/profile_state.dart';
import 'package:social_app/features/profile/presentation/cubits/my_profile_cubit.dart';


class MyProfileScreen extends StatefulWidget {
  const MyProfileScreen({
    super.key,
  });

  @override
  State<MyProfileScreen> createState() => _MyProfileScreenState();
}

class _MyProfileScreenState extends State<MyProfileScreen> {
  late String _uId;
  late MyProfileCubit _cubit;
  late SessionService _sessionService;

  @override
  void initState() {
    super.initState();
    _cubit = MyProfileCubit.get(context);
    _sessionService = sl<SessionService>();
    _uId = _sessionService.currentUid;
    _cubit.getProfileInfo(uId: _uId);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MyProfileCubit, ProfileState>(
        builder: (context, state) {
          return state.when(
            onInitial: () => const InitialStateWidget(text: 'Your account does not exist.'),
            onLoading: () => const LoadingStateWidget(),
            onLoaded: (data) =>
                ProfileLayout(
                  uploadImage: (postModel) =>
                      _cubit.uploadImage(postModel: postModel),
                  sessionService: _sessionService,
                  messageResult: data.messageResult,
                  deleteRequests: (userId) =>
                      _cubit.cancelRequests(userId: userId),
                  deleteFriendship: (userId) =>
                      _cubit.deleteFriendship(userId: userId),
                  userInfoModel: data.userInfoModel,
                  changeIndexButtons: (index) =>
                      _cubit.changeIndexButtons(index),
                  insertFriendsRequests: (userId) =>
                      _cubit.insertFriendsRequests(userId: userId),
                  currentButtonScreen: data.currentButtonScreen,
                  friendshipButtonKey: data.friendshipButtonKey,
                  onAdd: (postModel) async =>
                  await _cubit.addShare(
                      userId: postModel.myId,
                      postId: postModel.myDocId
                  ),
                  onToggle: (isActive, postModel) async =>
                  await _cubit.toggleLike(
                      isActive: isActive,
                      postModel: postModel
                  ),
                  onUpsert: (postModel) async {
                    await _cubit.upsertPostToRepository(postModel: postModel);
                    if (!context.mounted) return;
                    PostCoordinator.upsertPost(
                        context,
                        postModel: postModel,
                        group: PostSyncGroups.photo
                    );
                  },
                  onRemove: (postModel) async {
                    if (postModel.postIsShared) {
                      await _cubit.removeShare(
                          userId: postModel.myId,
                          postId: postModel.myDocId
                      );
                    }
                    await _cubit.removePostFromRepository(postModel: postModel);
                    if (!context.mounted) return;
                    PostCoordinator.removePost(
                        context,
                        postModel: postModel,
                        group: PostSyncGroups.photo
                    );
                  },
                ),
            onError: (error) => error.buildErrorWidget(),
          );
        }
    );
  }
}
