import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../modules/profile_screen/cubit.dart';
import '../../shared/constants/user_details.dart';
import 'package:social_app/models/info_model.dart';
import 'package:social_app/models/post_model.dart';
import '../../shared/cubit_states/cubit_states.dart';
import '../../shared/componentes/post_components.dart';
import '../../shared/componentes/public_components.dart';
import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';


class ProfileItemsInfoBuilder extends StatefulWidget {
  final ProfileCubit cubit;
  const ProfileItemsInfoBuilder({
    required this.cubit, 
    super.key});

  @override
  State<ProfileItemsInfoBuilder> createState() => _ProfileItemsInfoBuilderState();
}

class _ProfileItemsInfoBuilderState extends State<ProfileItemsInfoBuilder> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScrollPosts);
  }

  void _onScrollPosts() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200.0 && widget.cubit.isLoadingMore) {
      widget.cubit.listenerScreens[widget.cubit.currentButton];
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileCubit, CubitStates>(
        builder: (context, state) {
          widget.cubit.setProfileCubit(widget.cubit);
          var profileInfo = widget.cubit.profileInfoList;
          String lengthProfileImages = (widget.cubit.profileImagesList.length + 1)
              .toString();
          String lengthCoverImages = (widget.cubit.coverImagesList.length + 1)
              .toString();

          return SingleChildScrollView(
            controller: _scrollController,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildProfileHeader(
                    profileInfo!,
                    context,
                    lengthProfileImages,
                    lengthCoverImages,
                    widget.cubit
                ),
                _buildUserInfo(
                  friendCubit: widget.cubit,
                  profileInfo: profileInfo
                ),
                BuildButtonsList(
                    items: widget.cubit.buttons,
                    onTap: (value) {
                      setState(() {
                        widget.cubit.changeIndexButtons(value, profileInfo.userId);
                      });
                    }
                ),
                widget.cubit.buttonsScreens[widget.cubit.currentButton],
              ],
            ),
          );
        },
    );
  }
}


class BuildButtonsList extends StatefulWidget {
  final List<ButtonModel> items;
  Function(int)? onTap;

  BuildButtonsList({
    required this.items,
    this.onTap,
    super.key,
  });

  @override
  State<BuildButtonsList> createState() => _BuildButtonsListState();
}

class _BuildButtonsListState extends State<BuildButtonsList> {
  int activeButtonId = 0;

  void changeIndex(int id) {
    activeButtonId = id;
    widget.onTap!(id);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: widget.items.length,
            itemBuilder: (context, index) {
              final button = widget.items[index];
              final isActive = button.id == activeButtonId;

              return ButtonItem(
                  button: button,
                  isActive: isActive,
                  onTap: () {
                    changeIndex(button.id);
                  },
              );
            },
          ),
    );
  }
}


class ButtonItem extends StatelessWidget {
  final ButtonModel button;
  final bool isActive;
  final VoidCallback onTap;

  const ButtonItem({
    required this.button,
    required this.isActive,
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: Container(
        decoration: BoxDecoration(
          color: isActive ? Colors.black : Colors.white,
          borderRadius: BorderRadius.circular(30.0),
          border: Border.all(color: Colors.black),
        ),
        child: TextButton(
          onPressed: onTap,
          child: Center(
            child: Text(
              button.label,
              style: TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.w700,
                color: isActive ? Colors.white : Colors.black,
              ),
            ),
          ),
        ),
      ),
    );
  }
}


Future<void> createPost(String folderName ,String titleName, BuildContext context, ProfileCubit cubit)async {
  final file = await pickImage();

  navigator(
      context, CreatePost(
      buttonName: 'Update',
      titleName: titleName,
      postModel: PostModel(
          file: file,
          userPost: file!.path,
          postType: folderName,
          pathType: 'image'
      ),
      onPressed: (postModel) {
        cubit.uploadImage(postModel: postModel);
      }
    )
  );
}


Widget _buildProfileHeader(
    InfoModel profileInfo,
    BuildContext context,
    String profileDocUid,
    String coverDocUid,
    ProfileCubit cubit
    ) {
  return Stack(
    children: [
      InkWell(
        onTap: () {
          navigator(
            context,
            ViewImage(postModel: profileInfo.coverImage!,),
          );
        },
        child: Container(
          width: double.infinity,
          height: 200.0,
          child: Image.network(
            profileInfo.coverImage!.userPost ?? '',
            fit: BoxFit.cover,
          ),
        ),
      ),
      profileInfo.userId == UserDetails.uId
          ?
      BuildCameraIcon(left: 345.0,
          top: 160.0,
          onTap: () =>
              createPost('coverImage', 'Create cover photo', context, cubit))
          : const SizedBox(),
      _buildProfileImage(profileInfo, context, cubit),
      profileInfo.userId == UserDetails.uId ?
      BuildCameraIcon(
          left: 120.0,
          top: 220.0,
          onTap: () =>
              createPost('profileImage', 'Create profile picture', context, cubit)) :
      profileInfo.isOnline == true ?
      const Padding(
        padding: EdgeInsets.only(
          left: 125.0,
          top: 225.0,
        ),
        child: CircleAvatar(
          radius: 7.0,
          backgroundColor: Colors.blue,
        ),
      ) : const SizedBox(),
    ],
  );
}


class BuildCameraIcon extends StatelessWidget {
  final double left;
  final double top;
  final VoidCallback onTap;

  const BuildCameraIcon({
    required this.left,
    required this.top,
    required this.onTap,
    super.key
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: left, top: top),
      child: ClipOval(
        child: Material(
          child: InkWell(
            splashColor: Colors.blue,
            onTap: onTap,
            child:
            Container(
              width: 30.0,
              height: 30.0,
              child: Icon(Icons.camera),
            ),
          ),
        ),
      ),
    );
  }
}


Widget _buildProfileImage(InfoModel profileInfo, BuildContext context, ProfileCubit profileCubit) {
  return Padding(
    padding: const EdgeInsets.only(left: 10.0, top: 100.0),
    child:
        ClipOval(
          child: Material(
            child: InkWell(
              splashColor: Colors.blue,
              onTap: () {
                navigator(context,
                    ViewImage(postModel: profileInfo.profileImage!));
              },
              child:
                  Container(
                    width: 150.0,
                    height: 150.0,
                    child: profileInfo.profileImage != null?
                    Image.network(
                      profileInfo.profileImage!.userPost ?? '',
                      fit: BoxFit.cover,
                    ): Icon(Icons.person, size: 50.0),
              ),
            ),
          ),
        ),
  );
}


Widget _buildUserInfo({
  required InfoModel profileInfo,
  required ProfileCubit friendCubit,
}) {
  return Row(
    children: [
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 10.0, top: 10.0),
            child: Text(
              profileInfo.userName ?? 'Unknown',
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 25.0, fontWeight: FontWeight.bold),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 15.0, bottom: 10.0),
            child: Text(
              profileInfo.userState,
              style: TextStyle(fontSize: 15.0, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
      SizedBox(width: 10.0,),
      profileInfo.userId != UserDetails.uId ?
      friendshipButton(
          cubit: friendCubit
      ) : SizedBox(),
    ],
  );
}


Widget friendshipButton({
  required ProfileCubit cubit
}) {
  if (cubit.isFriend) {
    return FriendButton(
        buttonName: 'Unfriend',
        onPressed: () =>
            cubit.deleteFriendship(userId: cubit.profileInfoList!.userId!)
    );
  }
  else if (cubit.isRequest) {
    return FriendButton(
        buttonName: 'Cancel Request',
        onPressed: () =>
            cubit.deleteRequests(userId: cubit.profileInfoList!.userId!)
    );
  }
  else {
    return FriendButton(
        buttonName: 'Add Friend',
        backgroundColor: Colors.blue.shade900,
        textColor: Colors.white,
        onPressed: () =>
            cubit.insertFriendsRequests(userId: cubit.profileInfoList!.userId!)
    );
  }
}


class MainProfileLayout extends StatelessWidget {
  const MainProfileLayout({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileCubit, CubitStates>(
        builder: (context, localState) {
          final profileCubit = ProfileCubit
              .get(context, key: const ValueKey('otherProfile'));
          profileCubit.setProfileCubit(profileCubit);
          return Scaffold(
              appBar: AppBar(
                elevation: 0.0,
                scrolledUnderElevation: 0.0,
              ),
              body: profileListInfoBuilder(
                profileCubit: profileCubit,
              )
          );
        }
    );
  }
}


Widget profileListInfoBuilder({
  required ProfileCubit profileCubit,
}) {
  return ConditionalBuilder(
    condition: profileCubit.profileInfoList != null,
    builder: (context) => ProfileItemsInfoBuilder(cubit: profileCubit),
    fallback: (context) => SizedBox()
  );
}
