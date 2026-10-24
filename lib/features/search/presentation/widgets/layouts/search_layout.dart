import 'package:flutter/material.dart';
import 'package:social_app/core/constants/app_sizes.dart';
import 'package:social_app/core/data/models/my_model.dart';
import 'package:social_app/core/constants/app_paddings.dart';
import 'package:social_app/core/constants/app_text_styles.dart';
import '../../../../profile/presentation/screens/user_profile_screen.dart';
import 'package:social_app/core/presentation/widgets/navigation/navigator.dart';


class SearchLayout extends StatelessWidget {
  final List<MyModel> searchData;

  const SearchLayout({
    super.key,
    required this.searchData
  });

  Widget _searchItemsBuilder({
    required MyModel userModel,
    required BuildContext context
  }) {
    return InkWell(
      onTap: () {
        BuildNavigator.build(
            context: context,
            link: UserProfileScreen(friendId: userModel.myId));
      },
      child: Padding(
        padding: AppPaddings.all10,
        child: Row(
          children: [
            SizedBox(
              width: AppSizes.size40,
              height: AppSizes.size40,
              child: ClipOval(
                child: Image.network(
                  userModel.myImageUrl,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Padding(
              padding: AppPaddings.onlyLeft10,
              child: Text(userModel.myName,
                style: AppTextStyles.boldLarge,
              ),
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
        child: ListView.separated(
            itemBuilder: (context, index) =>
                _searchItemsBuilder(
                    userModel: searchData[index],
                    context: context
                ),
            separatorBuilder: (context, index) => SizedBox(height: 1.0),
            itemCount: searchData.length
        )
    );
  }
}