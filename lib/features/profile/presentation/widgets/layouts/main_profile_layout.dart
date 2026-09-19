import '../../../cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_app/core/data/models/post_model.dart';
import 'package:social_app/core/services/session_service.dart';
import 'package:social_app/core/services/media_picker_service.dart';
import 'package:social_app/core/data/models/profile_info_model.dart';
import '../../../../../core/presentation/widgets/new/friend_button.dart';
import 'package:social_app/core/presentation/screens/create_post_screen.dart';
import 'package:social_app/core/presentation/widgets/navigation/navigator.dart';
import 'package:social_app/core/presentation/widgets/new/view_image_screen.dart';
import 'package:social_app/features/profile/presentation/cubits/main/main_profile_cubit.dart';


class MainProfileLayout extends StatefulWidget {
  final bool isLoadingMore;
  final int currentButtonScreen;
  final List<Widget> buttonsScreens;
  final SessionService sessionService;
  final List<ButtonModel> buttonsItems;
  final ProfileInfoModel profileInfoModel;
  final void Function(PostModel) uploadImage;
  final void Function(String) deleteRequests;
  final void Function(String) deleteFriendship;
  final void Function(String) insertFriendsRequests;
  final void Function(int, String) changeIndexButtons;
  const MainProfileLayout({
    super.key,
    required this.uploadImage,
    required this.buttonsItems,
    required this.isLoadingMore,
    required this.buttonsScreens,
    required this.sessionService,
    required this.deleteRequests,
    required this.deleteFriendship,
    required this.profileInfoModel,
    required this.changeIndexButtons,
    required this.currentButtonScreen,
    required this.insertFriendsRequests,
  });

  @override
  State<MainProfileLayout> createState() => _MainProfileLayoutState();
}

class _MainProfileLayoutState extends State<MainProfileLayout> {
  late String _uId;
  late String _currentUid;
  bool _isLoadingPosts = false;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _uId = widget.profileInfoModel.userId ?? '';
    _currentUid = widget.sessionService.currentUid;
    _scrollController.addListener(_onScrollPosts);
  }

  void _onScrollPosts() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200.0 &&
        widget.isLoadingMore) {
      _loadMorePosts();
    }
  }

  Future<void> _loadMorePosts() async {
    if (_isLoadingPosts) return;

    setState(() => _isLoadingPosts = true);
    await widget.cubit.listenerScreens[widget.currentButtonScreen];
    setState(() => _isLoadingPosts = false);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      controller: _scrollController,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildProfileHeader(),
          _buildUserInfo(),
          BuildButtonsList(
              items: widget.buttonsItems,
              onTap: (index) {
                setState(() {
                  widget.changeIndexButtons(
                      index, _uId);
                });
              }
          ),
          widget.buttonsScreens[widget.currentButtonScreen],
        ],
      ),
    );
  }

  Future<void> _createPost({
    required String titleName,
    required String folderName
  }) async {
    final file = await MediaPickerService.pickImage();

    BuildNavigator.build(
        context: context,
        link: CreatePostScreen(
          buttonName: 'Update',
          titleName: titleName,
          postModel: PostModel(
              file: file,
              userPost: file!.path,
              postType: folderName,
              pathType: 'image'
          ),
          uId: _currentUid,
          onPressed: (postModel) {
            widget.uploadImage(postModel);
          },
        )
    );
  }

  Widget _buildProfileHeader() {
    return Stack(
      children: [
        InkWell(
          onTap: () {
            BuildNavigator.build(
              context: context,
              link: ViewImageScreen(postModel: widget.profileInfoModel.coverImage!),
            );
          },
          child: Container(
            width: double.infinity,
            height: 200.0,
            child: Image.network(
              widget.profileInfoModel.userPost ?? '',
              fit: BoxFit.cover,
            ),
          ),
        ),
        _uId == _currentUid
            ?
        BuildCameraIcon(
            left: 345.0,
            top: 160.0,
            onTap: () =>
                _createPost(
                    folderName: 'coverImage', titleName: 'Create cover photo'))
            : const SizedBox(),
        _buildProfileImage(),
        _uId == _currentUid ?
        BuildCameraIcon(
            left: 120.0,
            top: 220.0,
            onTap: () =>
                _createPost(
                    folderName: 'profileImage',
                    titleName: 'Create profile picture')) :
        widget.profileInfoModel.isOnline == true ?
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

  Widget _buildProfileImage() {
    return Padding(
      padding: const EdgeInsets.only(left: 10.0, top: 100.0),
      child:
      ClipOval(
        child: Material(
          child: InkWell(
            splashColor: Colors.blue,
            onTap: () {
              BuildNavigator.build(
                  context: context,
                  link: ViewImageScreen(postModel: widget.profileInfoModel.profileImage!));
            },
            child:
            SizedBox(
              width: 150.0,
              height: 150.0,
              child: widget.profileInfoModel.profileImage != null ?
              Image.network(
                widget.profileInfoModel.profileImage!.userPost ?? '',
                fit: BoxFit.cover,
              ) : Icon(Icons.person, size: 50.0),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUserInfo() {
    return Row(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 10.0, top: 10.0),
              child: Text(
                widget.profileInfoModel.userName ?? 'Unknown',
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 25.0, fontWeight: FontWeight.bold),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 15.0, bottom: 10.0),
              child: Text(
                widget.profileInfoModel.userState,
                style: TextStyle(fontSize: 15.0, fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
        SizedBox(width: 10.0,),
        _uId != _currentUid ?
        friendshipButton() : SizedBox(),
      ],
    );
  }

  Widget friendshipButton() {
    if (isFriend) {
      return FriendButton(
          buttonName: 'Unfriend',
          onPressed: () =>
              widget.deleteFriendship(_uId)
      );
    }
    else if (isRequest) {
      return FriendButton(
          buttonName: 'Cancel Request',
          onPressed: () =>
              widget.deleteRequests(_uId)
      );
    }
    else {
      return FriendButton(
          buttonName: 'Add Friend',
          backgroundColor: Colors.blue.shade900,
          textColor: Colors.white,
          onPressed: () =>
              widget.insertFriendsRequests(_uId)
      );
    }
  }
}


class BuildButtonsList extends StatefulWidget {
  final List<ButtonModel> items;
  final Function(int)? onTap;

  const BuildButtonsList({
    required this.items,
    this.onTap,
    super.key,
  });

  @override
  State<BuildButtonsList> createState() => _BuildButtonsListState();
}

class _BuildButtonsListState extends State<BuildButtonsList> {
  late int _activeButtonId;

  @override
  void initState() {
    super.initState();
    _activeButtonId = 0;
  }

  void changeIndex(int id) {
    _activeButtonId = id;
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
              final isActive = button.id == _activeButtonId;

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
            SizedBox(
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




