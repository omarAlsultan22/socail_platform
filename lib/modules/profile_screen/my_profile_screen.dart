import 'cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../shared/constants/user_details.dart';
import '../../layout/profile_layout/main_profile_layout.dart';
import 'package:social_app/shared/cubit_states/cubit_states.dart';


class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    ProfileCubit.get(context, key: const ValueKey('myProfile'))
      ..getProfileInfo(uid: UserDetails.uId)
      ..getFriends(userId: UserDetails.uId)
      ..getProfileData(userId: UserDetails.uId)
      ..checkIsFriend(userId: UserDetails.uId);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileCubit, CubitStates>(
        builder: (context, state) {
          final profileCubit = ProfileCubit
              .get(context, key: const ValueKey('myProfile'));
          profileCubit.setProfileCubit(profileCubit);
          return profileListInfoBuilder(
            profileCubit: profileCubit,
          );
        }
    );
  }
}


