import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_app/modules/interactions/likes_list/cubit.dart';
import 'package:video_player/video_player.dart';
import '../../../models/post_model.dart';
import '../../../modules/home_screen/cubit.dart';
import '../../../modules/interactions/comments_list/comments_list.dart';
import '../../../modules/interactions/likes_list/likes_list.dart';
import '../../../modules/main_screen/cubit.dart';
import '../../../modules/profile_screen/cubit.dart';
import '../../../modules/profile_screen/user_profile.dart';
import '../cubit_states/cubit_states.dart';
import 'constants.dart';
import 'public_components.dart';

Widget smallMenu({
  required String buttonName,
  required Future<void> Function() onPressed,
  required BuildContext context,
}) =>
  Expanded(
      child: InkWell(
        onTap: () async {
          await onPressed();
        },
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(buttonName,
            style: TextStyle(
                color: Colors.black
            ),
          ),
        ),
      )
  );

class ViewImage extends StatefulWidget {
  final PostModel postModel;
  const ViewImage({
    required this.postModel,
    super.key
  });

  @override
  State<ViewImage> createState() => _ViewImageState();
}

class _ViewImageState extends State<ViewImage> {
  late bool isActive;
  late int likes;
  late int comments;
  late int shares;

  void likeToggle(){
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

  @override
  void initState() {
    super.initState();
    likes = widget.postModel.likesNumber ?? 0;
    comments = widget.postModel.commentsNumber ?? 0;
    shares = widget.postModel.sharesNumber ?? 0;
    isActive = widget.postModel.isActive;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 15.0),
                child: IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(Icons.close, size: 25.0),
                ),
              ),
            ],
          ),
          SizedBox(height: 50.0),
          Expanded(
            child: Container(
              height: 200.0,
              width: double.infinity,
              child: widget.postModel.userPost != null
                  ? Image(
                image: NetworkImage(widget.postModel.userPost ?? ''),
                fit: BoxFit.cover,
              )
                  : Icon(Icons.person, size: 100.0),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(
                right: 10.0, left: 10.0, top: 10.0),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.postModel.userName!,
                            style: const TextStyle(
                              fontSize: 15.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Row(
                            children: [
                              Text(
                                '${getTimeAgo(widget.postModel.dateTime!)} . ',
                                style: TextStyle(fontSize: 13.0),
                              ),
                              Icon(map[widget.postModel.userState], size: 15.0),
                            ],
                          ),
                          if (widget.postModel.friendText != null)
                            Text(widget.postModel.friendText ?? ''),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10.0),
                            child: InkWell(
                              onTap: () {
                                navigator(
                                  context,
                                  LikesScreen(docId: widget.postModel.docId ?? ''),
                                );
                              },
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
                                                navigator(
                                                  context,
                                                  LikesScreen(docId: widget.postModel.docId!),
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
                                            onTap: () => navigator(
                                              context,
                                              CommentsScreen(docId: widget.postModel.docId!, userId: widget.postModel.userId,),
                                            ),
                                            child: Padding(
                                              padding: EdgeInsets.only(right: 15),
                                              child: Text('${comments.toString()} comments'),
                                            ),
                                          ),
                                        if (shares > 0)
                                          GestureDetector(
                                            onTap: () => navigator(
                                              context,
                                              CommentsScreen(docId: widget.postModel.docId!, userId: widget.postModel.userId),
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
                        ],
                      ),
                    ),
                  ],
                ),
                Container(height: 1.0, color: Colors.grey),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    iconButton(
                      onPressed: likeToggle,
                      icon: Icon(isActive ? Icons.favorite : Icons.favorite_border),
                      tooltip: 'Like',
                    ),
                    iconButton(
                      onPressed: () {
                        navigator(
                          context,
                          CommentsScreen(docId: widget.postModel.docId!, userId: widget.postModel.userId),
                        );
                      },
                      icon: Icon(Icons.comment_outlined),
                      tooltip: 'Comment',
                    ),
                    iconButton(
                      onPressed: () {
                        navigator(
                          context,
                          CreatePost(
                            titleName: 'Share Post',
                            buttonName: 'Share Now',
                            postModel: widget.postModel,
                            onPressed: (postModel) {
                              navigator(
                                context,
                                CreatePost(
                                  titleName: 'Share Post',
                                  buttonName: 'Share Now',
                                  postModel: widget.postModel,
                                  onPressed: (newPostModel) {
                                    HomeCubit
                                        .get(context).insertAndUpdatePosts(postModel: newPostModel);
                                    ProfileCubit
                                        .get(context)
                                        .insertAndUpdatePosts(postModel: newPostModel);
                                  },
                                ),
                              );
                            },
                          ),
                        );
                      },
                      icon: Icon(Icons.share),
                      tooltip: 'share',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


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

  void likeToggle(){
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
      navigator(context, UserProfile(userId: widget.postModel!.userId!));
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
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
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
                  if (widget.postModel!.friendId != null && widget.postModel!.friendId!.isNotEmpty)
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
                          '${getTimeAgo(dateTime)} . ',
                          style: TextStyle(fontSize: fontSize * 0.75),
                        ),
                        Icon(
                          map[state ?? ''],
                          size: iconSize,
                        ),
                      ],
                    ),
                ],
              ),
            ],
          ),
          if (widget.postModel!.userText!.isNotEmpty && widget.postModel!.userText != null)
            Padding(
              padding: const EdgeInsets.only(top: 8.0, left: 8.0, right: 8.0),
              child: Text(widget.postModel!.userText!),
            ),
        ],
      ),
    );
  }

  void _animationController(){
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
              animation.value == value && widget.postModel!.userId == UserDetails.uId ?
              smallMenu(
                context: context,
                buttonName: 'Edit',
                onPressed: () async{
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          CreatePost(
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
              smallMenu(
                context: context,
                buttonName: 'Delete',
                onPressed: () async {
                  await showExitDialog(
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
                              navigator(
                                context,
                                LikesScreen(docId: widget.postModel!.docId!, userId: widget.userId),
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
                          onTap: () => navigator(
                            context,
                            CommentsScreen(docId: widget.postModel!.docId!, userId: widget.userId),
                          ),
                          child: Padding(
                            padding: EdgeInsets.only(right: 15),
                            child: Text('${comments.toString()} comments'),
                          ),
                        ),
                      if (shares > 0)
                        GestureDetector(
                          onTap: () => navigator(
                            context,
                            CommentsScreen(docId: widget.postModel!.docId!, userId: widget.userId),
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
            iconButton(
              onPressed: likeToggle,
              icon: Icon(isActive ? Icons.favorite : Icons.favorite_border),
              tooltip: 'Like',
            ),
            iconButton(
              onPressed: () {
                navigator(
                  context,
                  CommentsScreen(docId: widget.postModel!.docId ?? ''),
                );
              },
              icon: Icon(Icons.comment_outlined),
              tooltip: 'Comment',
            ),
            iconButton(
              onPressed: () {
                navigator(
                  context,
                  CreatePost(
                    titleName: 'Share Post',
                    buttonName: 'Share Now',
                    postModel: widget.postModel,
                    onPressed: (newPostModel) {
                      HomeCubit
                          .get(context).insertAndUpdatePosts(postModel: newPostModel);
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
        return buildVideoContent(
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
          navigator(
            context,
            ViewImage(postModel: widget.postModel!),
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

class buildVideoContent extends StatefulWidget {
  final PostModel postModel;
  final BuildContext context;
  final VideoPlayerController? fullScreenVideoController;
  final double? width;
  final double? height;
  const buildVideoContent({
    required this.postModel,
    required this.context,
    required this.fullScreenVideoController,
    this.width,
    this.height,
    super.key});

  @override
  State<buildVideoContent> createState() => _buildVideoContentState();
}

class _buildVideoContentState extends State<buildVideoContent> {

  @override
  Widget build(BuildContext context) {
    if (widget.postModel.userPost == null || widget.postModel.userPost!.isEmpty) {
      return Container(
        height: widget.height ?? 400.0,
        width: widget.width ?? double.infinity,
        color: Colors.grey,
        child: Center(child: Text('There is no available video')),
      );
    }

    widget.postModel.videoController ??= VideoPlayerController.network(widget.postModel.userPost!)
      ..initialize().then((_) {
        if (mounted) setState(() {});
      });
    return GestureDetector(
      onTap: () => _showFullVideo(postModel: widget.postModel, context: context, fullScreenVideoController: widget.fullScreenVideoController),
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            height: widget.height ?? 400.0,
            width: widget.width ?? double.infinity,
            child: AspectRatio(
              aspectRatio: widget.postModel.videoController!.value.aspectRatio,
              child: VideoPlayer(widget.postModel.videoController!),
            ),
          ),
          if (!widget.postModel.videoController!.value.isPlaying)
            Container(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                  Icons.play_arrow, size: 50, color: Colors.white),
            ),
        ],
      ),
    );
  }
}

void _showFullVideo({
  required PostModel postModel,
  required BuildContext context,
  required VideoPlayerController? fullScreenVideoController
}) async {
  if (postModel.file == null) return;

  fullScreenVideoController = VideoPlayerController.network(postModel.userPost!);
  await fullScreenVideoController.initialize();
  fullScreenVideoController.play();

  showDialog(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          fullScreenVideoController!.addListener(() {
            setState(() {});
          });

          return WillPopScope(
            onWillPop: () async {
              await fullScreenVideoController!.pause();
              await fullScreenVideoController!.dispose();
              fullScreenVideoController = null;
              return true;
            },
            child: Dialog(
              backgroundColor: Colors.black,
              insetPadding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AspectRatio(
                    aspectRatio: fullScreenVideoController!.value
                        .aspectRatio,
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          if (fullScreenVideoController!.value.isPlaying) {
                            fullScreenVideoController!.pause();
                          } else {
                            fullScreenVideoController!.play();
                          }
                        });
                      },
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          VideoPlayer(fullScreenVideoController!),

                          if (!fullScreenVideoController!.value.isPlaying)
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.3),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.play_arrow,
                                size: 50,
                                color: Colors.white,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: Column(
                      children: [
                        VideoProgressIndicator(
                          fullScreenVideoController!,
                          allowScrubbing: true,
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          colors: const VideoProgressColors(
                            playedColor: Colors.blue,
                            bufferedColor: Colors.grey,
                            backgroundColor: Colors.grey,
                          ),
                        ),

                        _buildVideoTimeIndicator(
                          position: fullScreenVideoController!.value
                              .position,
                          duration: fullScreenVideoController!.value
                              .duration,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}

Widget _buildVideoTimeIndicator({
  required Duration position,
  required Duration duration,
}) {
  String twoDigits(int n) => n.toString().padLeft(2, '0');
  final minutes = twoDigits(position.inMinutes.remainder(60));
  final seconds = twoDigits(position.inSeconds.remainder(60));
  final totalMinutes = twoDigits(duration.inMinutes.remainder(60));
  final totalSeconds = twoDigits(duration.inSeconds.remainder(60));

  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(
        '$minutes:$seconds',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
        ),
      ),
      Text(
        '$totalMinutes:$totalSeconds',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
        ),
      ),
    ],
  );
}

Map<String, IconData> map = {
  'only_me': Icons.lock,
  'friends': Icons.person,
  'public': Icons.public,
};



String getTimeAgo(DateTime date) {
  final now = DateTime.now();
  final diff = now.difference(date);

  if (diff.inSeconds < 60) return 'now';

  //if (diff.inSeconds < 60) return '${diff.inSeconds}s';

  if (diff.inMinutes < 60) return '${diff.inMinutes}m';

  if (diff.inHours < 24) return '${diff.inHours}h';

  if (diff.inDays < 7) return '${diff.inDays}d';

  if(diff.inDays < 30) return '${diff.inDays}w';

  if (diff.inDays < 365) return '${(diff.inDays/ 30).floor()}mo';

  return '${(diff.inDays/365).floor()}y';
}


class CreatePost extends StatefulWidget {
  PostModel? postModel;
  final String buttonName;
  final String titleName;
  Function(PostModel) onPressed;


  CreatePost({
    super.key,
    this.postModel,
    required this.buttonName,
    required this.titleName,
    required this.onPressed
  });

  @override
  State<CreatePost> createState() => _CreatePostState();
}

class _CreatePostState extends State<CreatePost> {
  final textController = TextEditingController();
  String? selectedValue;

  @override
  void initState() {
    super.initState();
    widget.postModel ??= PostModel();
    if(widget.postModel!.userId == UserDetails.uId) {
      textController.text = widget.postModel!.userText ?? '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return splitScreen(
      titleName: widget.titleName,
      buildUserInfoSection: BuildUserInfoSection(
        onPressed: (value) =>
            setState(() =>
            selectedValue = value
            ),
      ),
      buildPostInputSection: BuildPostInputSection(
        textController: textController,),
      buildImageUploadSection: BuildImageUploadSection(
        postModel: widget.postModel,
        onTap: (postModel) => setState(() => widget.postModel = postModel),
      ),
      buildSubmitButton: BuildSubmitButton(
        state: selectedValue,
        postModel: widget.postModel,
        folderName: 'posts',
        buttonName: widget.buttonName,
        textController: textController,
        onPressed: (postModel) => widget.onPressed(postModel),
      ),
    );
  }
}

Widget splitScreen({
  required String titleName,
  required Widget buildUserInfoSection,
  required Widget buildPostInputSection,
  required Widget buildImageUploadSection,
  required Widget buildSubmitButton,
}) {
  return Scaffold(
    appBar: AppBar(
      title: Center(child: Text(titleName)),
    ),
    body: Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          buildUserInfoSection,
          buildPostInputSection,
          Expanded(child: buildImageUploadSection),
          buildSubmitButton,
        ],
      ),
    ),
  );
}

class BuildUserInfoSection extends StatefulWidget {
  Function(String) onPressed;
  BuildUserInfoSection({
    required this.onPressed,
    super.key
  });

  @override
  State<BuildUserInfoSection> createState() => _BuildUserInfoSectionState();
}

class _BuildUserInfoSectionState extends State<BuildUserInfoSection> {
  String? selectedValue;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Padding(
          padding: const EdgeInsets.only(right: 10.0),
          child: Container(
            height: 50.0,
            width: 50.0,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(50.0),
              border: UserDetails.image.isEmpty? Border.all(color: Theme.of(context).brightness == Brightness.light?
                  Colors.black : Colors.white
              ) : null,
              image: DecorationImage(
                image: NetworkImage(UserDetails.image),
                fit: BoxFit.cover,
              ),
            ),
            child: UserDetails.image.isEmpty?
            Icon(Icons.person) : SizedBox(),
          ),
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              UserDetails.name,
              style: TextStyle(
                fontSize: 12.0,
                fontWeight: FontWeight.bold,
                fontFamily: UserDetails.name,
              ),
            ),
            DropdownButton<String>(
              value: selectedValue ?? 'public',
              items: items.map((item) {
                return DropdownMenuItem<String>(
                  value: item['value'],
                  child: Row(
                    children: [
                      item['icon'],
                      const SizedBox(width: 8.0),
                      Text(item['text']),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  widget.onPressed(value);
                  setState(() {
                    selectedValue = value;
                  });
                  widget.onPressed(selectedValue!);
                }
              },
              hint: const Text('Select Visibility'),
            ),
          ],
        ),
      ],
    );
  }
}

class BuildPostInputSection extends StatelessWidget {
  final TextEditingController textController;
  const BuildPostInputSection({required this.textController, super.key});

  @override
  Widget build(BuildContext context) {
    return buildInputField(
      controller: textController,
      keyboardType: TextInputType.text,
      decoration: const InputDecoration(
        border: InputBorder.none,
        hintText: 'Write here anything',
      ),
    );
  }
}

class BuildImageUploadSection<T> extends StatefulWidget {
  PostModel? postModel;
  void Function(PostModel) onTap;
  BuildImageUploadSection({
    this.postModel,
    required this.onTap,
    super.key});

  @override
  State<BuildImageUploadSection<T>> createState() => _BuildImageUploadSection<T>();
}

class _BuildImageUploadSection<T> extends State<BuildImageUploadSection<T>> {

  void _setMedia(File file, String pathType){
    setState((){
      widget.postModel!
        ..file = file
        ..userPost = file.path
        ..pathType = pathType;
    });
    widget.onTap(widget.postModel!);
  }

  Future<void> _showMediaPicker(BuildContext context) async {
    await showModalBottomSheet(
      context: context,
      builder: (context) =>
          SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.photo_library),
                  title: const Text('Image from the exhibition'),
                  onTap: () async {
                    Navigator.pop(context);
                    final file = await pickImage();
                    _setMedia(file!, 'image');
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.video_library),
                  title: const Text('Video from the exhibition'),
                  onTap: () async {
                    Navigator.pop(context);
                    final file = await pickVideo();
                    _setMedia(file!, 'video');
                  },
                ),
              ],
            ),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: (widget.postModel == null || widget.postModel!.userPost == null) ?
      InkWell(
        onTap: () async =>
            _showMediaPicker(context),
        child: Container(
            height: 200.0,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.photo_library, size: 50.0),
                    Icon(Icons.video_collection, size: 50.0),
                  ],
                ),
                const Text('Add photos/videos'),
              ],
            )
        ),
      )
          : Container(
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Column(
          children: [
            if(widget.postModel!.userText != null &&
                widget.postModel!.userId != UserDetails.uId)...[
              Padding(
                padding: const EdgeInsets.only(left: 15.0),
                child: Text(
                  widget.postModel!.userText ?? '',
                  style: const TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ),
            ],
            if(widget.postModel!.userPost != null)...[
              widget.postModel!.pathType == 'image' ?
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: widget.postModel!.file != null? FileImage(widget.postModel!.file!) : 
                      NetworkImage(widget.postModel!.userPost!),
                      fit: BoxFit.cover,
                    ),
                  ),
                  height: 350.0,
                  width: double.infinity,
                ),
              ) : Expanded(child: Container(
                  child: PublishingConfirmationScreen(file: widget.postModel!.file!))),
            ]
          ],
        ),
      ),
    );
  }
}

class BuildSubmitButton extends StatefulWidget {
  PostModel? postModel;
  String? state;
  final String folderName;
  final String buttonName;
  void Function(PostModel) onPressed;
  final TextEditingController textController;
  BuildSubmitButton({
    required this.state,
    required this.postModel,
    required this.textController,
    required this.folderName,
    required this.buttonName,
    required this.onPressed,
    super.key});

  @override
  State<BuildSubmitButton> createState() => _BuildSubmitButtonState();
}

class _BuildSubmitButtonState extends State<BuildSubmitButton> {
  bool isLoading = false;

  void setData() async {
    try {
      setState(() => isLoading = true);

      if ((widget.textController.text.isEmpty || widget.textController.text.trim() == '') &&
          (widget.postModel!.userPost == null || widget.postModel!.userPost!.isEmpty)) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Please enter post details or add an image'),
          backgroundColor: Colors.red.shade700,
        ));
        return;
      }

      if(widget.postModel!.userId == UserDetails.uId && widget.buttonName == 'Share Now'){
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('You cannot share your post'),
          backgroundColor: Colors.red.shade700,
        ));
        return;
      }

      if(widget.postModel!.userId != UserDetails.uId && widget.buttonName == 'Share Now') {
        PostModel newPostModel = PostModel();
        final docId = await createDoc();
        setState(() =>
        newPostModel
          ..docId = docId
          ..userPost = widget.postModel!.userPost
          ..friendId = widget.postModel!.userId
          ..friendName = widget.postModel!.userName
          ..friendImage = widget.postModel!.userImage
          ..friendText = widget.postModel!.userText
          ..friendState = widget.postModel!.userState
          ..friendIsOnline = widget.postModel!.isOnline
          ..originalDateTime = widget.postModel!.dateTime
          ..userState = widget.state ?? 'public'
          ..userText = widget.textController.text
          ..pathType = widget.postModel!.pathType
          ..postType = widget.postModel!.postType
          ..isOnline = true
          ..dateTime = DateTime.now()
          ..videoController = widget.postModel!.videoController
          ..sharesNumber = 0
          ..likesNumber = 0
          ..commentsNumber = 0
        );
        widget.onPressed(newPostModel);
      }
      else {
        final map = await checkFile(widget.postModel!.file!);
        final docId = await createDoc();
        setState(() =>
        widget.postModel = PostModel(
          docId: docId,
          userText: widget.textController.text,
          userPost: map!['url'] ?? '',
          userState: widget.state ?? 'public',
          pathType: widget.postModel!.pathType ?? map['type'],
          dateTime: DateTime.now(),
          isOnline: true)
        );
        widget.onPressed(widget.postModel!);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('The post has been published successfully'),
          backgroundColor: Colors.green.shade700,
        ));
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red.shade700,
        ));
      }
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      child: MaterialButton(
          onPressed: () => setData(),
          color: Colors.blue.shade900,
          child: isLoading ?
          Center(child: CircularProgressIndicator(
              color: Colors.white)) :
          Text(
            widget.buttonName,
            style: const TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.bold,
                color: Colors.white
            ),
          )
      ),
    );
  }
  Future<String>createDoc()async{
    return FirebaseFirestore.instance.collection('posts').doc().id;
  }
}

final List<Map<String, dynamic>> items = [
  {
    'value': 'public',
    'icon': Icon(Icons.public),
    'text': 'Public',
  },
  {
    'value': 'friends',
    'icon': Icon(Icons.person),
    'text': 'Friends',
  },
  {
    'value': 'only_me',
    'icon': Icon(Icons.lock),
    'text': 'Only me',
  },
];


class PublishingConfirmationScreen extends StatefulWidget {
  final File file;
  late VideoPlayerController? videoController;

  PublishingConfirmationScreen({
    required this.file,
    this.videoController,
    super.key,
  });

  @override
  State<PublishingConfirmationScreen> createState() => _PublishingConfirmationScreenState();
}

class _PublishingConfirmationScreenState extends State<PublishingConfirmationScreen> {
  bool _isVideoInitialized = false;
  bool _isPlaying = false;
  late final VideoPlayerController _videoController;
  late VoidCallback _listener;

  @override
  void initState() {
    super.initState();
    _videoController = widget.videoController ?? VideoPlayerController.file(widget.file);
    _initializeVideo();
    _listener = () {
      if (!_videoController.value.isInitialized) return;

      if (_videoController.value.position >= _videoController.value.duration) {
        _videoController.pause();
        _videoController.seekTo(Duration.zero);
        if (mounted) {
          setState(() {
            _isPlaying = false;
          });
        }
      }
    };
  }

  Future<void> _initializeVideo() async {
    try {
      await _videoController.initialize();
      _videoController.addListener(_listener);
      if (mounted) {
        setState(() {
          _isVideoInitialized = true;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load video: ${e.toString()}')),
        );
      }
    }
  }

  @override
  void dispose() {
    _videoController.removeListener(_listener);
    _videoController.pause();
    _videoController.dispose();
    super.dispose();
  }

  Future<void> _toggleVideoPlayback() async {
    if (!_isVideoInitialized) return;

    setState(() => _isPlaying = !_isPlaying);

    if (_isPlaying) {
      await _videoController.play();
    } else {
      await _videoController.pause();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          Expanded(
            flex: 7,
            child: _buildVideoDisplay(),
          ),
          Expanded(
            flex: 3,
            child: _buildVideoControls(),
          ),
        ],
      ),
    );
  }

  Widget _buildVideoDisplay() {
    if (!_isVideoInitialized) {
      return Center(child: CircularProgressIndicator());
    }

    return AspectRatio(
      aspectRatio: _videoController.value.aspectRatio,
      child: VideoPlayer(_videoController),
    );
  }

  Widget _buildVideoControls() {
    if (!_isVideoInitialized) {
      return SizedBox();
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ValueListenableBuilder(
            valueListenable: _videoController,
            builder: (context, value, child) {
              return Column(
                children: [
                  Slider(
                    value: value.position.inMilliseconds.toDouble(),
                    min: 0,
                    max: value.duration.inMilliseconds.toDouble(),
                    onChanged: (newValue) {
                      _videoController.seekTo(Duration(milliseconds: newValue.round()));
                    },
                    onChangeEnd: (newValue) {
                      if (_isPlaying) {
                        _videoController.play();
                      }
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(_formatDuration(value.position)),
                        Text(_formatDuration(value.duration)),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
          // زر التشغيل/الإيقاف
          Container(
            decoration: BoxDecoration(
                border: Border.all(
                    color: Theme.of(context).brightness == Brightness.light
                        ? Colors.black
                        : Colors.white
                ),
                borderRadius: BorderRadius.circular(50.0)
            ),
            child: IconButton(
              icon: Icon(
                _isPlaying ? Icons.pause : Icons.play_arrow,
                size: 36,
              ),
              onPressed: _toggleVideoPlayback,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration d) {
    return '${d.inMinutes}:${(d.inSeconds % 60).toString().padLeft(2, '0')}';
  }
}