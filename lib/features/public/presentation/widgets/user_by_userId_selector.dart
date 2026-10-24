import 'package:flutter/cupertino.dart';
import '../../data/models/user_details.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_app/core/data/models/post_model.dart';
import 'package:social_app/core/presentation/widgets/empty_state_widget.dart';
import 'package:social_app/features/user_details/presentation/cubits/friends_details_cubit.dart';
import 'package:social_app/features/user_details/presentation/states/friends_details_state.dart';


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
    return BlocSelector<FriendsDetailsCubit, FriendsDetailsState, UserDetails?>(
        selector: (state) => state.friendsDetails[postModel.myId],
        builder: (context, userDetails) {
          if (userDetails == null) return const EmptyStateWidget();
          return builder(userDetails);
        }
    );
  }
}