import 'cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_app/layout/add_friends_layout/add_friends_layout.dart';


class AddNewFriendsScreen extends StatelessWidget {
  const AddNewFriendsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(create: (context) =>
    AddNewFriendsCubit()
      ..getSuggestsUsers(),
        child: AddNewFriendsLayout()
    );
  }
}

