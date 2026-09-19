import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/service _locator.dart';
import '../widgets/layouts/main_profile_layout.dart';
import 'package:social_app/core/services/session_service.dart';
import '../../../../core/presentation/widgets/states/initial_state.dart';
import 'package:social_app/core/presentation/widgets/states/loading_state.dart';
import 'package:social_app/features/profile/presentation/states/profile_state.dart';
import 'package:social_app/features/profile/presentation/cubits/user_profile_cubit.dart';


class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({
    super.key,
  });

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  late String _uId;
  late UserProfileCubit _cubit;
  late SessionService _sessionService;

  @override
  void initState() {
    super.initState();
    _cubit = UserProfileCubit.get(context);
    _sessionService = sl<SessionService>();
    _uId = _sessionService.currentUid;
    _cubit
      ..getProfileInfo(uid: _uId)
      ..getFriends(userId: _uId)
      ..getProfileData(userId: _uId)
      ..checkIsFriend(userId: _uId);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserProfileCubit, ProfileState>(
        builder: (context, state) {
          return state.when(
            onInitial: () => const InitialStateWidget(),
            onLoading: () => const LoadingStateWidget(),
            onLoaded: (data) {
              return MainProfileLayout(
                uploadImage: (postModel) =>
                    _cubit.uploadImage(postModel: postModel),
                sessionService: _sessionService,
                deleteRequests: (userId) =>
                    _cubit.deleteRequests(userId: userId),
                deleteFriendship: (userId) =>
                    _cubit.deleteFriendship(userId: userId),
                profileInfoModel: data.profileInfoModel,
                changeIndexButtons: (index, userId) =>
                    _cubit.changeIndexButtons(index, userId),
                insertFriendsRequests: (userId) =>
                    _cubit.insertFriendsRequests(userId: userId),
              );
            },
            onError: (error) => error.buildErrorWidget(),
          );
        }
    );
  }
}
