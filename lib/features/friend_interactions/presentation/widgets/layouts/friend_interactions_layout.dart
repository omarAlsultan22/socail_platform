import 'package:flutter/material.dart';
import '../../../../../core/data/models/user_model.dart';
import '../../../../profile/presentation/screens/user_profile_screen.dart';
import '../../../../../core/presentation/widgets/navigation/navigator.dart';


class FriendInteractionsLayout extends StatelessWidget {
  final bool isActive;
  final Map<String, String> map;
  final void Function(int) refuseButton;
  final void Function (int) acceptButton;
  final List<UserModel> notificationData;

  const FriendInteractionsLayout({
    super.key,
    required this.isActive,
    required this.map,
    required this.notificationData,
    required this.acceptButton,
    required this.refuseButton,
  });

  Widget _friendRequestItem({
    required UserModel userModel,
    required Map<String, String> buttons,
    required VoidCallback acceptButton,
    required VoidCallback refuseButton,
    required BuildContext context
  }) {
    return InkWell(
      onTap: () {
        BuildNavigator.build(
            context: context, link: UserProfile(userId: userModel.userId!));
      },
      child: Padding(
        padding: const EdgeInsets.only(left: 10.0),
        child: Row(
          children: [
            Container(
              width: 50.0,
              height: 50.0,
              child: ClipOval(
                child: Image.network(
                    userModel.userImage!,
                    fit: BoxFit.cover
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    userModel.userName!,
                    style: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Row(
                    children: [
                      MaterialButton(
                        onPressed: acceptButton,
                        color: Colors.blue.shade900,
                        child: Text(
                          '${buttons['AcceptButton']}',
                          style: TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      SizedBox(width: 10.0),
                      MaterialButton(
                        onPressed: refuseButton,
                        color: Colors.grey,
                        child: Text(
                          '${buttons['RefuseButton']}',
                          style: TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        notificationData.isNotEmpty ?
        Padding(
            padding: const EdgeInsets.all(8.0),
            child:
            Text(
              '${map['title']}',
              style: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
              ),
            )
        ) : SizedBox(),
        ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemBuilder: (context, index) =>
              _friendRequestItem(
                  userModel: notificationData[index],
                  buttons: map,
                  acceptButton: () => acceptButton(index),
                  refuseButton: () => refuseButton(index),
                  context: context
              ),
          itemCount: notificationData.length,
        ),
      ],
    );
  }
}
