import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../cubits/main/main_profile_cubit.dart';
import '../../../../../core/di/service _locator.dart';
import '../../../../../core/data/models/post_model.dart';
import 'package:social_app/core/data/models/user_model.dart';
import 'package:social_app/core/services/session_service.dart';
import '../../../../../core/presentation/widgets/list_builder.dart';
import 'package:social_app/core/presentation/widgets/new/post_card.dart';
import 'package:social_app/core/presentation/widgets/navigation/navigator.dart';
import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:social_app/features/profile/presentation/screens/friend_profile_screen.dart';


class PostsScreen extends StatelessWidget {
  final MainProfileCubit profileCubit;
  final SessionService sessionService;

  const PostsScreen({
    super.key,
    required this.profileCubit,
    required this.sessionService
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileCubit, CubitStates>(
        builder: (context, state) {
          ProfileInfoModel? profileData = profileCubit.profileInfoModel;
          var friends = profileCubit.friendsList;
          var homeData = profileCubit.postsDataList;
          int len = friends.length;

          return Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Details',
                    style: TextStyle(
                        fontSize: 18.0, fontWeight: FontWeight.bold),
                  ),
                  personalDetails(icon: Icons.work,
                      textAddress: 'Works at',
                      textValue: profileData!.userWork),
                  personalDetails(icon: Icons.home_filled,
                      textAddress: 'Lives in',
                      textValue: profileData.userLive),
                  personalDetails(icon: Icons.location_on_sharp,
                      textAddress: 'From',
                      textValue: profileData.userFrom),
                  personalDetails(icon: Icons.favorite,
                      textAddress: profileData.userRelational),
                  Container(height: 1.0, color: Colors.grey),
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: GestureDetector(
                      onTap: () =>
                          BuildNavigator.build(context: context,
                              link: friendsScreen(profileCubit)
                          ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text('Friends', style: TextStyle(
                              fontSize: 18.0, fontWeight: FontWeight.bold)),
                          Text('friends ${friends.length}',
                              style: TextStyle(fontSize: 16.0)),
                        ],
                      ),
                    ),
                  ),
                  showFriends(friends: friends,
                      len: len,
                      count: 3,
                      startIndex: 0,
                      context: context),
                  showFriends(friends: friends,
                      len: len,
                      count: 3,
                      startIndex: 3,
                      context: context),
                  Container(height: 1.0, color: Colors.grey),
                  profileData.userId == sessionService.currentUid ?
                  postInput(
                    context: context,
                  ) : SizedBox(),
                  Container(height: 1.0, color: Colors.grey),
                  _profileBuilder(
                      profileData: homeData,
                  )
                ],
              )
          );
        }
    );
  }

  Widget _profileBuilder({
    required List<PostModel> profileData,
  }) {
    return ConditionalBuilder(
      condition: profileData.isNotEmpty,
      builder: (context) =>
          SizedBox(
            child: ListView.separated(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) =>
                  PostCard(
                    index: index.toString(),
                    postModel: profileData[index],
                    sessionService: sl<SessionService>(),
                    length: (profileData.length + 1).toString(),
                  ),
              separatorBuilder: (context, index) => const SizedBox(height: 1.0),
              itemCount: profileData.length,
            ),
          ),
      fallback: (context) =>
      const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }


  Widget friendsScreen(ProfileCubit cubit) =>
      Scaffold(
        appBar: AppBar(
          scrolledUnderElevation: 0.0,
        ),
        body: ListBuilder(
            list: cubit.friendsList,
            object: (friend) =>
                LikeModelLayout(like: friend),
            fallback: Text('There no any friends yet')
        ),
      );
}


Padding personalDetails({
  required IconData icon,
  required String textAddress,
  String? textValue
})=>
    Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
          children: [
            Icon(icon),
            Text('  $textAddress ',
              style: TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.normal
              ),
            ),
            Text(textValue ?? '',
              style: TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold
              ),
            )
          ]
      ),
    );


Widget friendImage({
  required String image,
  required String text,
  required VoidCallback onTap,
}) =>
    Expanded(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            AspectRatio(
              aspectRatio: 1,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                height: 100.0,
                child: InkWell(
                  onTap: onTap,
                  child: Image(image: NetworkImage(image),fit: BoxFit.cover),
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: InkWell(
                onTap: onTap,
                child: Text(text,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(),),
              ),
            )
          ],
        ),
      ),
    );


Row showFriends({
  required int len,
  required int count,
  required int startIndex,
  required BuildContext context,
  required List<UserModel> friends
}) {
  if (startIndex >= len) return Row();

  int remaining = len - startIndex;
  int displayCount = remaining < count ? remaining : count;

  return Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: List.generate(displayCount, (index) {
      int friendIndex = startIndex + index;
      if (friendIndex >= len) return SizedBox();

      return friendImage(
          image: friends[friendIndex].userImage!,
          text: friends[friendIndex].userName!,
          onTap: () =>
              BuildNavigator.build(context: context,
                  link: FriendProfileScreen(
                      userId: friends[friendIndex].userId)
              )
      );
    }),
  );
}


