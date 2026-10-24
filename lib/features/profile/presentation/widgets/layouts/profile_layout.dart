import '../build_camera_icon.dart';
import '../build_buttons_list.dart';
import 'package:flutter/material.dart';
import '../../screens/posts_screen.dart';
import '../../screens/photos_screen.dart';
import '../../screens/videos_screen.dart';
import '../../../../public/data/models/user_details.dart';
import 'package:social_app/core/constants/app_sizes.dart';
import 'package:social_app/core/constants/app_colors.dart';
import 'package:social_app/core/constants/app_spaces.dart';
import 'package:social_app/core/constants/app_strings.dart';
import 'package:social_app/core/data/models/post_model.dart';
import 'package:social_app/core/constants/app_paddings.dart';
import 'package:social_app/core/constants/app_text_styles.dart';
import 'package:social_app/core/data/models/message_result.dart';
import 'package:social_app/core/data/models/user_info_model.dart';
import 'package:social_app/core/constants/friend_button_state.dart';
import 'package:social_app/core/services/data/session_service.dart';
import '../../../../../core/presentation/widgets/friend_button.dart';
import '../../../../../core/services/domain/i_media_upload_service.dart';
import 'package:social_app/features/profile/constants/profile_lists.dart';
import 'package:social_app/core/presentation/screens/view_post_screen.dart';
import '../../../../../core/presentation/widgets/current_user_selector.dart';
import 'package:social_app/core/presentation/screens/create_post_screen.dart';
import 'package:social_app/core/presentation/widgets/navigation/navigator.dart';


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
  final IMediaUploadService mediaUploadService;
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
    required this.mediaUploadService,
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
    FriendButtonState.friend.key: FriendButton(
        buttonName: FriendButtonState.unfriend.label,
        onPressed: () =>
            widget.deleteFriendship(_uId)
    ),

    FriendButtonState.request.key: FriendButton(
        buttonName: FriendButtonState.cancelRequest.label,
        onPressed: () =>
            widget.deleteRequests(_uId)
    ),

    FriendButtonState.unfriend.key: FriendButton(
        buttonName: FriendButtonState.addFriend.label,
        backgroundColor: AppColors.primaryBlue,
        textColor: AppColors.white,
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
    final file = await widget.mediaUploadService.pickImage();

    if (!mounted) return;

    BuildNavigator.build(
        context: context,
        link: CreatePostScreen(
          buttonName: 'Update',
          titleName: titleName,
          postModel: PostModel(
              file: file,
              pathType: AppStrings.image,
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
            height: AppSizes.size200,
            child: !widget.userInfoModel.coverImageIsEmpty ?
            Image.network(
              widget.userInfoModel.coverImageUrl,
              fit: BoxFit.cover,
            ) : const SizedBox.shrink(),
          ),
        ),
        _uId == _currentUid ?
        BuildCameraIcon(
            left: 345.0,
            top: 160.0,
            onTap: () =>
                _createPost(
                  userDetails: userDetails,
                  folderName: AppStrings.coverImage,
                  titleName: 'Create cover photo',
                )
        )
            : const SizedBox.shrink(),
        _buildProfileImage(userDetails),
        _uId == _currentUid ?
        BuildCameraIcon(
            left: 120.0,
            top: 220.0,
            onTap: () =>
                _createPost(
                    userDetails: userDetails,
                    folderName: AppStrings.profileImage,
                    titleName: 'Create profile picture'
                )
        ) :
        widget.userInfoModel.meIsOnline == true ?
        Padding(
          padding: AppPaddings.onlyLeft125Top225,
          child: CircleAvatar(
            radius: AppSizes.onlineIndicatorLarge,
            backgroundColor: AppColors.primaryBlue,
          ),
        ) : const SizedBox.shrink(),
      ],
    );
  }

  Widget _buildProfileImage(UserDetails userDetails) {
    return Padding(
      padding: AppPaddings.onlyLeft10Top100,
      child:
      ClipOval(
        child: Material(
          child: InkWell(
            splashColor: AppColors.primaryBlue,
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
              width: AppSizes.avatarLarge,
              height: AppSizes.avatarLarge,
              child: !widget.userInfoModel.profileImageIsEmpty ?
              Image.network(
                widget.userInfoModel.profileImageUrl,
                fit: BoxFit.cover,
              ) : Icon(Icons.person, size: AppSizes.xl),
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
              padding: AppPaddings.onlyLeft10Top10,
              child: Text(
                userDetails.myName,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.boldTitle,
              ),
            ),
            Padding(
              padding: AppPaddings.onlyLeft15Bottom10,
              child: Text(
                widget.userInfoModel.myState,
                style: TextStyle(fontSize: 15.0, fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
        AppSpaces.horizontal_10,
        _uId != _currentUid ?
        friendshipButton() : SizedBox.shrink(),
      ],
    );
  }

  Widget friendshipButton() {
    return _friendshipButton[widget.friendshipButtonKey] ?? SizedBox.shrink();
  }
}