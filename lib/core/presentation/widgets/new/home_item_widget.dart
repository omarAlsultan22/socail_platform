import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../../../../features/main/cubit.dart';
import '../../../data/models/post_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:video_player/video_player.dart';
import '../../../../features/profile/cubit.dart';
import 'package:social_app/core/constants/user_details.dart';
import '../../../../features/interactions/likes_list/cubit.dart';
import '../../../../features/interactions/likes_list/likes_list.dart';
import 'package:social_app/features/public/utils/time_ago_helper.dart';
import '../../../../features/interactions/comments_list/comments_list.dart';
import 'package:social_app/features/public/constants/public_constants.dart';
import 'package:social_app/core/presentation/widgets/navigation/navigator.dart';
import 'package:social_app/core/presentation/widgets/new/view_image_screen.dart';
import 'package:social_app/core/presentation/widgets/new/small_menu_widget.dart';
import 'package:social_app/core/presentation/widgets/new/exit_dialog_helper.dart';
import 'package:social_app/core/presentation/widgets/new/icon_button_widget.dart';
import 'package:social_app/core/presentation/widgets/new/video_content_widget.dart';
import 'package:social_app/features/public/presentation/screens/create_post_screen.dart';
import 'package:social_app/features/profile/presentation/screens/user_profile_screen.dart';


class HomeItem extends StatefulWidget {
  final PostModel? postModel;
  final ProfileCubit? profileCubit;
  final String? length;
  final String? index;
  final void Function(bool)? deletePost;
  final String? userId;

  HomeItem({
    super.key,
    this.postModel,
    this.profileCubit,
    this.deletePost,
    this.length,
    this.index,
    this.userId,
  });

  @override
  _HomeItemState createState() => _HomeItemState();
}

class _HomeItemState extends State<HomeItem> with SingleTickerProviderStateMixin {
  bool isActive = false;
  bool isOpen = false;
  bool changeColor = false;
  double value = 35.0;
  late int likes;
  late int comments;
  late int shares;
  late Animation<double> animation;
  late AnimationController controller;
  final commentController = TextEditingController();
  VideoPlayerController? _fullScreenVideoController;


  @override
  void initState() {
    super.initState();
    likes = widget.postModel!.likesNumber ?? 0;
    comments = widget.postModel!.commentsNumber ?? 0;
    shares = widget.postModel!.sharesNumber ?? 0;
    isActive = widget.postModel!.isActive;

    addAnimationValue();
    controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    animation = Tween(begin: 0.0, end: value).animate(controller)
      ..addListener(() {
        setState(() {});
      });
  }

  void addAnimationValue() {
    if (widget.postModel!.userId == UserDetails.uId) {
      setState(() {
        value = 70.0;
      });
    }
  }


  void _toggleAnimation(bool isOpen) {
    if (isOpen) {
      controller.forward();
    } else {
      controller.reverse();
    }
  }

  void likeToggle() {
    setState(() {
      isActive = !isActive;
      likes += isActive ? 1 : -1;
    });
    chickLike(
        isActive: isActive,
        postModel: widget.postModel!
    );
  }


  Future<void> chickLike({
    required bool isActive,
    required PostModel postModel,
  }) async {
    if (isActive) {
      await LikesCubit.get(context).addLike(
          postId: postModel.docId!, userId: postModel.userId!);
    }
    else {
      LikesCubit.get(context).deleteLike(
          postId: postModel.docId!, userId: postModel.userId!);
    }
  }

  void userProfile(MainLayoutCubit cubit) {
    if (widget.userId != null && widget.userId == widget.postModel!.userId) {
      return;
    }
    else if (widget.postModel!.userId != UserDetails.uId) {
      BuildNavigator.build(context: context,
          link: UserProfile(userId: widget.postModel!.userId!));
    }
    else {
      if (cubit.currentScreen == 1) {
        Navigator.pop(context);
      }
      cubit.changeIndexScreen(4);
    }
  }

  Widget build(BuildContext context) {
    if (widget.postModel == null) return const SizedBox();
    final isDarkMode = Theme
        .of(context)
        .brightness == Brightness.dark;
    final borderColor = isDarkMode ? Colors.white : Colors.black;
    final isPost = widget.postModel?.userPost != null;

    return BlocBuilder<MainLayoutCubit, CubitStates>(
      builder: (context, state) {
        final cubit = MainLayoutCubit.get(context);

        return Card(
          margin: EdgeInsets.zero,
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildUserInfo(cubit, true),
                  if (widget.postModel!.friendId != null &&
                      widget.postModel!.friendId!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(left: 15.0, right: 15.0),
                      child: Center(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            border: Border(
                              top: BorderSide(width: 0.5, color: borderColor),
                              right: BorderSide(width: 0.5, color: borderColor),
                              left: BorderSide(width: 0.5, color: borderColor),
                              bottom: isPost
                                  ? BorderSide.none
                                  : BorderSide(width: 0.5, color: borderColor),
                            ),
                            borderRadius: isPost
                                ? const BorderRadius.only(
                                topLeft: Radius.circular(10.0),
                                topRight: Radius.circular(10.0))
                                : BorderRadius.circular(10.0),
                          ),
                          child: SizedBox(
                            width: double.infinity,
                            child: _buildUserInfo(cubit, false),
                          ),
                        ),
                      ),
                    ),
                  _buildPostContent(widget.profileCubit),
                ],
              ),
              Positioned(
                top: 12.0,
                right: 0.0,
                child: _buildMoreOptions(),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildUserInfo(MainLayoutCubit cubit, bool isRealUser) {
    if (widget.postModel == null) return const SizedBox();

    final sizeFactor = isRealUser ? 1.0 : 0.8;
    final position = isRealUser ? 3.0 : 2.0;
    final avatarSize = 50.0 * sizeFactor;
    final fontSize = 20.0 * sizeFactor;
    final iconSize = 20.0 * sizeFactor;
    final onlineIndicatorSize = 5.0 * sizeFactor;
    final padding = EdgeInsets.only(
      top: 20.0,
      left: isRealUser ? 12.0 : 16.0,
      bottom: 15.0,
      right: 15.0,
    );

    final imageUrl = isRealUser
        ? widget.postModel?.userImage
        : widget.postModel?.friendImage;
    final name = isRealUser
        ? widget.postModel?.userName
        : widget.postModel?.friendName;
    final dateTime = isRealUser
        ? widget.postModel?.dateTime
        : widget.postModel?.originalDateTime;
    final state = isRealUser
        ? widget.postModel?.userState
        : widget.postModel?.friendState;

    return Padding(
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 15.0),
                child: Stack(
                  alignment: AlignmentDirectional.bottomEnd,
                  children: [
                    ClipOval(
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          splashColor: Colors.blue,
                          onTap: () => userProfile(cubit),
                          child: Container(
                            width: avatarSize,
                            height: avatarSize,
                            child: Image.network(
                              imageUrl ?? '',
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) =>
                                  Icon(Icons.person, size: avatarSize),
                            ),
                          ),
                        ),
                      ),
                    ),
                    if (widget.postModel?.isOnline == true)
                      Padding(
                        padding: EdgeInsetsDirectional.only(
                          bottom: position,
                          end: position,
                        ),
                        child: CircleAvatar(
                          radius: onlineIndicatorSize,
                          backgroundColor: Colors.blue,
                        ),
                      ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  InkWell(
                    onTap: () => userProfile(cubit),
                    child: Text(
                      name ?? '',
                      style: TextStyle(
                        fontSize: fontSize,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  if (dateTime != null)
                    Row(
                      children: [
                        Text(
                          '${TimeAgoHelper.getTimeAgo(dateTime)} . ',
                          style: TextStyle(fontSize: fontSize * 0.75),
                        ),
                        Icon(
                          PublicConstants.postStatuses[state ?? ''],
                          size: iconSize,
                        ),
                      ],
                    ),
                ],
              ),
            ],
          ),
          if (widget.postModel!.userText!.isNotEmpty &&
              widget.postModel!.userText != null)
            Padding(
              padding: const EdgeInsets.only(top: 8.0, left: 8.0, right: 8.0),
              child: Text(widget.postModel!.userText!),
            ),
        ],
      ),
    );
  }

  void _animationController() {
    setState(() {
      isOpen = !isOpen;
      _toggleAnimation(isOpen);
    });
  }

  Widget _buildMoreOptions() {
    return Column(
      children: [
        IconButton(
          onPressed: () => _animationController(),
          icon: Icon(Icons.more_horiz),
        ),
        Container(
          width: 100.0,
          height: isOpen ? animation.value : animation.value,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10.0),
              color: Colors.grey.shade300
          ),
          child: Column(
            children: [
              animation.value == value &&
                  widget.postModel!.userId == UserDetails.uId ?
              SmallMenuWidget(
                  context: context,
                  buttonName: 'Edit',
                  onPressed: () async {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            CreatePostScreen(
                                buttonName: 'Save',
                                titleName: 'UpdatePost',
                                postModel: widget.postModel,
                                onPressed: (postModel) {
                                  HomeCubit
                                      .get(context).insertAndUpdatePosts(
                                      postModel: postModel);
                                  ProfileCubit
                                      .get(context).insertAndUpdatePosts(
                                      postModel: postModel);
                                }
                            ),
                      ),
                    );
                    _animationController();
                  }
              ) : SizedBox(),
              animation.value == value ?
              SmallMenuWidget(
                context: context,
                buttonName: 'Delete',
                onPressed: () async {
                  await ExitDialogHelper.showExitDialog(
                      context: context,
                      onPressed: (val) =>
                      val ? widget.deletePost!(val) : null,
                      type: 'post'
                  );
                  _animationController();
                },
              ) : SizedBox(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPostContent(ProfileCubit? profileCubit) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildContent(profileCubit ?? ProfileCubit()),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10.0),
          child: Padding(
            padding: const EdgeInsets.only(left: 5.0),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (likes > 0)
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () =>
                              BuildNavigator.build(
                                context: context,
                                link: LikesScreen(
                                    docId: widget.postModel!.docId!,
                                    userId: widget.userId),
                              ),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(50.0),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(3.0),
                              child: Icon(
                                Icons.favorite,
                                size: 15,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 5.0),
                        Text(likes.toString()),
                      ],
                    ),
                  Row(
                    children: [
                      if (comments > 0)
                        GestureDetector(
                          onTap: () =>
                              BuildNavigator.build(
                                context: context,
                                link: CommentsScreen(
                                    docId: widget.postModel!.docId!,
                                    userId: widget.userId),
                              ),
                          child: Padding(
                            padding: EdgeInsets.only(right: 15),
                            child: Text('${comments.toString()} comments'),
                          ),
                        ),
                      if (shares > 0)
                        GestureDetector(
                          onTap: () =>
                              BuildNavigator.build(
                                context: context,
                                link: CommentsScreen(
                                    docId: widget.postModel!.docId!,
                                    userId: widget.userId),
                              ),
                          child: Text('${shares.toString()} shares'),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButtonWidget(
              onPressed: likeToggle,
              icon: Icon(isActive ? Icons.favorite : Icons.favorite_border),
              tooltip: 'Like',
            ),
            IconButton(
              onPressed: () {
                BuildNavigator.build(
                  context: context,
                  link: CommentsScreen(docId: widget.postModel!.docId ?? ''),
                );
              },
              icon: Icon(Icons.comment_outlined),
              tooltip: 'Comment',
            ),
            IconButtonWidget(
              onPressed: () {
                BuildNavigator.build(
                  context: context,
                  link: CreatePostScreen(
                    titleName: 'Share Post',
                    buttonName: 'Share Now',
                    postModel: widget.postModel,
                    onPressed: (newPostModel) {
                      HomeCubit
                          .get(context).insertAndUpdatePosts(
                          postModel: newPostModel);
                      ProfileCubit
                          .get(context)
                          .insertAndUpdatePosts(postModel: newPostModel);
                    },
                  ),
                );
              },
              icon: Icon(Icons.share),
              tooltip: 'Share',
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildContent(ProfileCubit? profileCubit) {
    switch (widget.postModel!.pathType) {
      case 'image':
        return _buildImageContent(profileCubit ?? ProfileCubit.get(context));
      case 'video':
        return VideoContentWidget(
            postModel: widget.postModel!,
            context: context,
            fullScreenVideoController: _fullScreenVideoController
        );
      default:
        return SizedBox();
    }
  }

  Widget _buildImageContent(ProfileCubit? profileCubit) =>
      Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: NetworkImage(widget.postModel!.userPost ?? ''),
            fit: BoxFit.cover,
          ),
          borderRadius: BorderRadius.circular(8.0),
        ),
        height: 400.0,
        width: double.infinity,
        child: InkWell(
          onTap: () {
            BuildNavigator.build(
              context: context,
              link: ViewImageScreen(postModel: widget.postModel!),
            );
          },
        ),
      );


  @override
  void dispose() {
    controller.dispose();
    _fullScreenVideoController?.dispose();
    super.dispose();
  }
}