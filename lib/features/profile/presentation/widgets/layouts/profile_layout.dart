import '../build_camera_icon.dart';
import '../build_buttons_list.dart';
import 'package:flutter/material.dart';
import '../../screens/posts_screen.dart';
import '../../screens/photos_screen.dart';
import '../../screens/videos_screen.dart';
import '../../../../public/data/models/user_details.dart';
import 'package:social_app/core/data/models/post_model.dart';
import 'package:social_app/core/services/session_service.dart';
import 'package:social_app/core/data/models/message_result.dart';
import 'package:social_app/core/data/models/user_info_model.dart';
import 'package:social_app/core/services/media_picker_service.dart';
import '../../../../../core/presentation/widgets/friend_button.dart';
import 'package:social_app/features/profile/constants/profile_lists.dart';
import '../../../../../core/presentation/widgets/current_user_selector.dart';
import 'package:social_app/core/presentation/screens/create_post_screen.dart';
import 'package:social_app/core/presentation/widgets/navigation/navigator.dart';
import 'package:social_app/core/presentation/screens/view_post_screen.dart';


class ProfileLayout extends StatefulWidget {
  final int currentButtonScreen;
  final String friendshipButtonKey;
  final MessageResult messageResult;
  final UserInfoModel userInfoModel;
  final SessionService sessionService;
  final void Function(PostModel) onAdd;
  final void Function(PostModel) onUpsert;
  final void Function(PostModel)? onRemove;
  final void Function(PostModel) uploadImage;
  final void Function(String) deleteRequests;
  final void Function(int) changeIndexButtons;
  final void Function(String) deleteFriendship;
  final void Function(bool, PostModel) onToggle;
  final void Function(String) insertFriendsRequests;

  const ProfileLayout({
    super.key,
    this.onRemove,
    required this.onAdd,
    required this.onUpsert,
    required this.onToggle,
    required this.uploadImage,
    required this.userInfoModel,
    required this.messageResult,
    required this.sessionService,
    required this.deleteRequests,
    required this.deleteFriendship,
    required this.changeIndexButtons,
    required this.friendshipButtonKey,
    required this.currentButtonScreen,
    required this.insertFriendsRequests,
  });

  @override
  State<ProfileLayout> createState() => _ProfileLayoutState();
}

class _ProfileLayoutState extends State<ProfileLayout> {
  late String _uId;
  late String _currentUid;

  List<Widget> get _buttonsScreens =>
      [
        PostsScreen(uId: _uId),
        PhotosScreen(uId: _uId),
        VideosScreen(uId: _uId),
      ];

  late final Map<String, FriendButton> _friendshipButton = {
    'friend': FriendButton(
        buttonName: 'Unfriend',
        onPressed: () =>
            widget.deleteFriendship(_uId)
    ),

    'request': FriendButton(
        buttonName: 'Cancel Request',
        onPressed: () =>
            widget.deleteRequests(_uId)
    ),

    'unfriend': FriendButton(
        buttonName: 'Add Friend',
        backgroundColor: Colors.blue.shade900,
        textColor: Colors.white,
        onPressed: () =>
            widget.insertFriendsRequests(_uId)
    )
  };

  @override
  void initState() {
    super.initState();
    _uId = widget.userInfoModel.myId;
    _currentUid = widget.sessionService.currentUid;
  }

  @override
  Widget build(BuildContext context) {
    return CurrentUserSelector(
        builder: (userDetails) =>
            SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildProfileHeader(userDetails),
                  _buildUserInfo(userDetails),
                  BuildButtonsList(
                      items: ProfileLists.buttonsModels,
                      onTap: (index) {
                        setState(() {
                          widget.changeIndexButtons(index);
                        });
                      }
                  ),
                  _buttonsScreens[widget.currentButtonScreen],
                ],
              ),
            )
    );
  }

  Future<void> _createPost({
    required String titleName,
    required String folderName,
    required UserDetails userDetails
  }) async {
    final file = await MediaPickerService.pickImage();

    if (!mounted) return;

    BuildNavigator.build(
        context: context,
        link: CreatePostScreen(
          buttonName: 'Update',
          titleName: titleName,
          postModel: PostModel(
              file: file,
              pathType: 'image',
              isProfilePost: true,
              userPost: file!.path,
              postType: folderName
          ),
          currentId: _currentUid,
          onPressed: (postModel) {
            widget.uploadImage(postModel);
          },
          userDetails: userDetails,
          messageResult: widget.messageResult,
        )
    );
  }

  Widget _buildProfileHeader(UserDetails userDetails) {
    return Stack(
      children: [
        InkWell(
          onTap: () {
            BuildNavigator.build(
              context: context,
              link: ViewPostScreen(
                onAdd: widget.onAdd,
                userDetails: userDetails,
                onToggle: widget.onToggle,
                onUpsert: widget.onUpsert,
                onRemove: widget.onRemove,
                messageResult: widget.messageResult,
                sessionService: widget.sessionService,
                postModel: widget.userInfoModel.coverImage!,
              ),
            );
          },
          child: SizedBox(
            width: double.infinity,
            height: 200.0,
            child: !widget.userInfoModel.coverImageIsEmpty ?
            Image.network(
              widget.userInfoModel.coverImageUrl,
              fit: BoxFit.cover,
            ): const SizedBox(),
          ),
        ),
        _uId == _currentUid ?
        BuildCameraIcon(
            left: 345.0,
            top: 160.0,
            onTap: () =>
                _createPost(
                  userDetails: userDetails,
                  folderName: 'coverImage',
                  titleName: 'Create cover photo',
                )
        )
            : const SizedBox(),
        _buildProfileImage(userDetails),
        _uId == _currentUid ?
        BuildCameraIcon(
            left: 120.0,
            top: 220.0,
            onTap: () =>
                _createPost(
                    userDetails: userDetails,
                    folderName: 'profileImage',
                    titleName: 'Create profile picture'
                )
        ) :
        widget.userInfoModel.meIsOnline == true ?
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

  Widget _buildProfileImage(UserDetails userDetails) {
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
                  link: ViewPostScreen(
                      onAdd: widget.onAdd,
                      userDetails: userDetails,
                      onToggle: widget.onToggle,
                      onUpsert: widget.onUpsert,
                      onRemove: widget.onRemove,
                      messageResult: widget.messageResult,
                      sessionService: widget.sessionService,
                      postModel: widget.userInfoModel.profileImage!
                  )
              );
            },
            child:
            SizedBox(
              width: 150.0,
              height: 150.0,
              child: !widget.userInfoModel.profileImageIsEmpty ?
              Image.network(
                widget.userInfoModel.profileImageUrl,
                fit: BoxFit.cover,
              ) : Icon(Icons.person, size: 50.0),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUserInfo(UserDetails userDetails) {
    return Row(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 10.0, top: 10.0),
              child: Text(
                userDetails.myName,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 25.0, fontWeight: FontWeight.bold),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 15.0, bottom: 10.0),
              child: Text(
                widget.userInfoModel.myState,
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
    return _friendshipButton[widget.friendshipButtonKey] ?? SizedBox();
  }
}