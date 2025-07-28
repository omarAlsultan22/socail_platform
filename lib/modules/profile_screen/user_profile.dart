import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_app/layout/profile_layout/main_profile_layout.dart';
import 'package:social_app/shared/cubit_states/cubit_states.dart';
import 'cubit.dart';

class UserProfile extends StatelessWidget {
  final String userId;

  const UserProfile({
    required this.userId,
    super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ProfileCubit>(
        key: const ValueKey('otherProfile'),
        create: (context) => ProfileCubit()
        ..getProfileInfo(uid: userId)
      ..getFriends(userId: userId)
      ..getProfileData(userId: userId)
      ..checkIsRequest(userId: userId)
      ..checkIsFriend(userId: userId),
        child: BlocConsumer<ProfileCubit, CubitStates>(
            listener: (context, localState) {},
            builder: (context, localState) {
              final profileCubit = ProfileCubit
                  .get(context, key: const ValueKey('otherProfile'));
              profileCubit.setProfileCubit(profileCubit);
              return Scaffold(
                  appBar: AppBar(
                    elevation: 0.0,
                    scrolledUnderElevation: 0.0,
                  ),
                  body: profileListInfoBuilder(
                        profileInfo: profileCubit,
                      )
              );
            }
        )
    );
  }
}
