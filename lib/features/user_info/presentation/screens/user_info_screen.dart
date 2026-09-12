import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/service _locator.dart';
import 'package:social_app/core/presentation/widgets/states/loading_state.dart';
import 'package:social_app/core/presentation/widgets/states/initial_state.dart';
import 'package:social_app/features/user_info/presentation/cubits/user_info_cubit.dart';
import 'package:social_app/features/user_info/presentation/states/user_info_state.dart';
import 'package:social_app/features/user_info/presentation/widgets/layouts/user_info_layout.dart';


class UserInfoScreen extends StatelessWidget {
  const UserInfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(create: (context) =>
    sl<UserInfoCubit>()
      ..getInfo(),
        child: BlocBuilder<UserInfoCubit, UserInfoState>(
            builder: (context, state) {
              final cubit = UserInfoCubit.get(context);
              return state.when(
                  onInitial: () =>
                      InitialStateWidget(text: 'No user info found'),
                  onLoading: () => LoadingStateWidget(),
                  onLoaded: (data) =>
                      UserInfoLayout(
                        messageResult: data.messageResult,
                        profileInfoModel: data.profileInfoModel,
                        onUpdate: ({
                          required String userFrom,
                          required String userLive,
                          required String userWork,
                          required String userState,
                          required String userRelational
                        }) =>
                            cubit.updateInfo(
                                userWork: userWork,
                                userLive: userLive,
                                userFrom: userFrom,
                                userState: userState,
                                userRelational: userRelational
                            ),
                      ),
                  onError: (failure) =>
                      failure.buildErrorWidget(
                          onRetry: () => cubit.getInfo()
                      )
              );
            }
        )
    );
  }
}

