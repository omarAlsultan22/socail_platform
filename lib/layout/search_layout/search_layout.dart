import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:flutter/material.dart';
import 'package:social_app/models/user_model.dart';
import 'package:social_app/modules/profile_screen/user_profile.dart';
import '../../shared/componentes/public_components.dart';

Widget searchItemsBuilder({
  required UserModel userModel,
  required BuildContext context

}) {
  return InkWell(
        onTap: () {
          navigator(context,UserProfile(userId: userModel.userId!));
        },
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Row(
            children: [
              Container(
                width: 40.0,
                height: 40.0,
                child: ClipOval(
                  child: Image.network(
                    userModel.userImage!,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(
                    left: 10.0),
                child: Text(userModel.userName!,
                  style: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold
                  ),
                ),
              )
            ],
          ),
        ),
  );
}


Widget searchListBuilder({
  required List<UserModel> searchData,
  required BuildContext context
}) {
  return ConditionalBuilder(
      condition: searchData.isNotEmpty,
      builder: (context) =>
          Expanded(
            child: ListView.separated(
                itemBuilder: (context, index) =>
                    searchItemsBuilder(
                    userModel: searchData[index],
                    context: context
                ),
                separatorBuilder: (context, index) => SizedBox(height: 1.0,),
                itemCount: searchData.length),
          ),
      fallback: (context) => Container());
}

