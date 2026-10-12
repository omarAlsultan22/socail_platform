import 'package:flutter/cupertino.dart';
import '../../data/models/user_details.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_app/core/data/models/post_model.dart';
import 'package:social_app/features/public/presentation/cubits/public_cubit.dart';
import 'package:social_app/features/public/presentation/states/public_state.dart';


class UserByUserIdSelector extends StatelessWidget {
  final PostModel postModel;
  final Widget Function(UserDetails) builder;

  const UserByUserIdSelector({
    super.key,
    required this.builder,
    required this.postModel
  });

  @override
  Widget build(BuildContext context) {
    return BlocSelector<PublicCubit, PublicState, UserDetails?>(
        selector: (state) => state.usersDetailsMap[postModel.myId],
        builder: (context, userDetails) {
          if (userDetails == null) return const SizedBox();
          return builder(userDetails);
        }
    );
  }
}
