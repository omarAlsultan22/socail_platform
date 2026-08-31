import 'package:flutter/material.dart';
import 'package:social_app/core/data/models/user_model.dart';
import '../../../../profile/presentation/screens/user_profile_screen.dart';
import 'package:social_app/core/presentation/widgets/navigation/navigator.dart';
import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';


class SearchLayout extends StatelessWidget {
  final List<UserModel> searchData;

  const SearchLayout({
    super.key,
    required this.searchData
  });

  Widget _searchItemsBuilder({
    required UserModel userModel,
    required BuildContext context
  }) {
    return InkWell(
      onTap: () {
        BuildNavigator.build(
            context: context, link: UserProfile(userId: userModel.userId!));
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

  @override
  Widget build(BuildContext context) {
    return ConditionalBuilder(
        condition: searchData.isNotEmpty,
        builder: (context) =>
            Expanded(
              child: ListView.separated(
                  itemBuilder: (context, index) =>
                      _searchItemsBuilder(
                          userModel: searchData[index],
                          context: context
                      ),
                  separatorBuilder: (context, index) => SizedBox(height: 1.0),
                  itemCount: searchData.length),
            ),
        fallback: (context) => Container());
  }
}

