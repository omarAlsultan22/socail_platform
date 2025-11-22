import '../../models/post_model.dart';
import 'package:flutter/material.dart';
import '../../modules/home_screen/cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../shared/constants/user_details.dart';
import 'package:social_app/models/info_model.dart';
import 'package:social_app/models/user_model.dart';
import '../../shared/cubit_states/cubit_states.dart';
import '../../shared/componentes/post_components.dart';
import '../../shared/componentes/public_components.dart';
import 'package:social_app/modules/profile_screen/cubit.dart';
import '../interactions_layout/likes_layout/likes_layout.dart';
import 'package:social_app/modules/profile_screen/user_profile_screen.dart';
import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';


class PostsScreen extends StatelessWidget {
  final ProfileCubit profileCubit;

  const PostsScreen({
    required this.profileCubit,
    super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileCubit, CubitStates>(
        builder: (context, state) {
          InfoModel? profileData = profileCubit.profileInfoList;
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
                          navigator(context,
                              friendsScreen(profileCubit)
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
                  profileData.userId == UserDetails.uId ?
                  postInput(
                    context: context,
                  ) : SizedBox(),
                  Container(height: 1.0, color: Colors.grey),
                  profileBuilder(
                      homeData: homeData,
                      deletePost: (postModel) {
                        if (postModel.userId == UserDetails.uId) {
                          profileCubit.deletePost(postModel: postModel);
                        }
                        HomeCubit.get(context).deletePost(postModel: postModel);
                      }
                  )
                ],
              )
          );
        }
    );
  }


  Widget profileBuilder({
    required List<PostModel> homeData,
    required void Function (PostModel) deletePost
  }) {
    return ConditionalBuilder(
      condition: homeData.isNotEmpty,
      builder: (context) =>
          SizedBox(
            child: ListView.separated(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) =>
                  HomeItem(
                    postModel: homeData[index],
                    length: (homeData.length + 1).toString(),
                    index: index.toString(),
                    deletePost: (val) =>
                    val
                        ? deletePost(homeData[index])
                        : null,
                    userId: profileCubit.userId,
                  ),
              separatorBuilder: (context, index) => const SizedBox(height: 1.0),
              itemCount: homeData.length,
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
                LikesModel(like: friend),
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
  required List<UserModel> friends,
  required int len,
  required int count,
  required int startIndex,
  required BuildContext context
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
            navigator(
                context, UserProfile(userId: friends[friendIndex].userId!)),
      );
    }),
  );
}


