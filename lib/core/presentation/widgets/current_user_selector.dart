import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../features/public/data/models/user_details.dart';
import 'package:social_app/core/presentation/widgets/empty_state_widget.dart';
import 'package:social_app/features/user_details/presentation/cubits/my_details_cubit.dart';
import 'package:social_app/features/user_details/presentation/states/my_details_state.dart';


class CurrentUserSelector extends StatelessWidget {
  final Widget Function(UserDetails) builder;

  const CurrentUserSelector({
    super.key,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    return BlocSelector<MyDetailsCubit, MyDetailsState, UserDetails?>(
        selector: (state) => state.userDetails,
        builder: (context, userDetails) {
          if (userDetails == null) return const EmptyStateWidget();
          return builder(userDetails);
        }
    );
  }
}