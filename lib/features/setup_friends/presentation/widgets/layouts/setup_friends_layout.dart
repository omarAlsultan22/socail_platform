import 'package:flutter/material.dart';
import '../../../../../core/data/models/my_model.dart';
import '../../../../main/presentation/screens/main_screen.dart';
import 'package:social_app/core/data/models/message_result.dart';
import '../../../../../core/presentation/widgets/list_builder.dart';
import '../../../../../core/presentation/widgets/layouts/user_row_layout.dart';
import 'package:social_app/core/presentation/widgets/navigation/navigator.dart';


class AddNewFriendsLayout extends StatefulWidget {
  final int friendsNumber;
  final VoidCallback onSave;
  final List<MyModel> friendsList;
  final MessageResult messageResult;
  final void Function(MyModel) onAdd;
  const AddNewFriendsLayout({
    super.key,
    required this.onAdd,
    required this.onSave,
    required this.friendsList,
    required this.friendsNumber,
    required this.messageResult});

  @override
  State<AddNewFriendsLayout> createState() => _AddNewFriendsLayoutState();
}

class _AddNewFriendsLayoutState extends State<AddNewFriendsLayout> {
  bool isActive = false;

  bool _checkButtonIsActive(int friendsNumber) {
    if (friendsNumber >= 10) {
      setState(() {
        isActive = true;
      });
      widget.onSave();
      return isActive;
    }
    return isActive;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        scrolledUnderElevation: 0.0,
        title: Text('Add New Friends'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListBuilder(
                list: widget.friendsList,
                object: (friend) =>
                    UserRowLayout(
                      userRow: friend,
                      onPressed: () => widget.onAdd(friend),
                    ),
                fallback: const Center(
                    child: CircularProgressIndicator())
            ),
          ),
          Container(
            width: double.infinity,
            color: isActive ? Colors.amber : null,
            child: MaterialButton(
              onPressed: _checkButtonIsActive(widget.friendsNumber)
                  ? () =>
                  BuildNavigator.build(context: context, link: MainScreen())
                  : null,
              child: Text('Finish'),
            ),
          )
        ],
      ),
    );
  }
}

