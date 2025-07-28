import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:flutter/material.dart';
import 'package:social_app/modules/profile_screen/user_profile.dart';
import '../../models/user_model.dart';
import '../../shared/componentes/public_components.dart';

Widget buildFriendListSection({
  required Map<String, String> map,
  required List<UserModel> notificationData,
  required void Function (int) acceptButton,
  required void Function(int) refuseButton,
  required bool isActive,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      notificationData.isNotEmpty?
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
      ): SizedBox(),
      ConditionalBuilder(
        condition: notificationData.isNotEmpty,
        builder: (context) =>
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) => _friendRequestItem(
                  userModel: notificationData[index],
                  buttons: map,
                  acceptButton: () => acceptButton(index),
                  refuseButton: () => refuseButton(index),
                  context: context
              ),
              itemCount: notificationData.length,
            ),
        fallback: (context) => isActive? Center(child: CircularProgressIndicator()): SizedBox(),
      ),
    ],
  );
}


Widget _friendRequestItem({
  required UserModel userModel,
  required Map<String, String> buttons,
  required VoidCallback  acceptButton,
  required VoidCallback refuseButton,
  required BuildContext context
}) {
  return InkWell(
    onTap: () {
      navigator(context, UserProfile(userId: userModel.userId!));
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
