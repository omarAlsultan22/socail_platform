import 'package:flutter/material.dart';
import '../../../../../core/data/models/user_model.dart';
import '../../../../main/presentation/screens/main_screen.dart';
import 'package:social_app/core/data/models/message_result.dart';
import '../../../../../core/presentation/widgets/list_builder.dart';
import '../../../../interactions/interactions_layout/like_model_layout.dart';


class AddNewFriendsLayout extends StatefulWidget {
  final int friendsNumber;
  final VoidCallback onSave;
  final List<UserModel> friendsList;
  final MessageResult messageResult;
  final void Function(UserModel) onAdd;
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

  bool _checkButtonIsActive(int addsNumber) {
    if (addsNumber >= 10) {
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
                    UserModelLayout(
                      like: friend,
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
              onPressed: _checkButtonIsActive(widget.friendsNumber) ? () =>
              {
                Navigator.push(context, MaterialPageRoute(
                    builder: (context) => MainScreen()))
              } : null,
              child: Text('Finish'),
            ),
          )
        ],
      ),
    );
  }
}

