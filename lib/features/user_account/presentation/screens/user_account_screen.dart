import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/service _locator.dart';
import 'package:social_app/core/presentation/widgets/states/loading_state.dart';
import 'package:social_app/core/presentation/widgets/states/initial_state.dart';
import 'package:social_app/features/user_account/presentation/cubits/user_account_cubit.dart';
import 'package:social_app/features/user_account/presentation/states/user_account_state.dart';
import 'package:social_app/features/user_account/presentation/widgets/layouts/user_account_layout.dart';


class UserAccountScreen extends StatelessWidget {
  const UserAccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(create: (context) =>
    sl<UserAccountCubit>()
      ..getAccount(),
        child: BlocBuilder<UserAccountCubit, UserAccountState>(
            builder: (context, state) {
              final cubit = UserAccountCubit.get(context);
              return state.when(
                  onInitial: () =>
                      InitialStateWidget(text: 'No user account found'),
                  onLoading: () => LoadingStateWidget(),
                  onLoaded: (data) =>
                      UserAccountLayout(
                          onUpdate: ({
                            required String firstName,
                            required String lastName
                          }) =>
                              cubit.updateAccount(
                                  firstName: firstName,
                                  lastName: lastName
                              ),
                          userAccount: data.userAccount,
                          messageResult: data.messageResult
                      ),
                  onError: (failure) =>
                      failure.buildErrorWidget(
                          onRetry: () => cubit.getAccount()
                      )
              );
            }
        )
    );
  }
}

