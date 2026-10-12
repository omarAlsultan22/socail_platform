import 'package:flutter/material.dart';
import 'package:social_app/core/data/models/my_model.dart';
import '../../../../core/presentation/widgets/list_builder.dart';
import 'package:social_app/core/presentation/widgets/layouts/user_row_layout.dart';


class UserRowBuilder extends StatelessWidget {
  final String? userId;
  final List<MyModel> userRowList;

  const UserRowBuilder({
    super.key,
    this.userId,
    required this.userRowList
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        scrolledUnderElevation: 0.0,
      ),
      body: ListBuilder(
        list: userRowList,
        object: (userRow) =>
            UserRowLayout(
              userId: userId,
              userRow: userRow,
            ),
        fallback: Center(
          child: Text(
            'There are no any likes',
          ),
        ),
      ),
    );
  }
}