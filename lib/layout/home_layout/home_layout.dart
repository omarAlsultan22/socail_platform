import 'dart:async';
import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_app/models/post_model.dart';
import 'package:social_app/modules/home_screen/cubit.dart';
import 'package:social_app/modules/main_screen/cubit.dart';
import 'package:video_player/video_player.dart';
import '../../modules/online_status_service/online_status_service.dart';
import '../../modules/profile_screen/user_profile.dart';
import '../../shared/componentes/constants.dart';
import '../../shared/componentes/post_components.dart';
import '../../shared/componentes/public_components.dart';
import '../../shared/cubit_states/cubit_states.dart';

class StatusScreen extends StatefulWidget {
  final List<PostModel> status;
  void Function(PostModel) onPressed;

  StatusScreen({
    super.key,
    required this.status,
    required this.onPressed,
  });

  @override
  State<StatusScreen> createState() => _StatusScreenState();
}

class _StatusScreenState extends State<StatusScreen> with TickerProviderStateMixin {

  int timeLeft = 2;
  Timer? timer;
  bool isPaused = false;
  int currentIndex = 0;
  double startLine = 0.0;
  bool isOpen = false;
  bool _isExiting = false;
  bool _isDisposed = false;
  bool _isCompleting = false;
  double value = 35.0;
  late Animation<double> animation;
  late AnimationController controller;
  int remainingFrames = 0;
  double totalDuration = 5.0;
  static double framesPerSecond = 60.0;
  double totalFrames = 5.0 * framesPerSecond;
  final onlineStatusService = OnlineStatusService();


  @override
  void initState() {
    super.initState();
    _initUserState();
    startTimer();
    addAnimationValue();
    controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    animation = Tween(begin: 0.0, end: value).animate(controller)
      ..addListener(() {
        setState(() {});
      });
  }

  Future<void> _initUserState() async {
    onlineStatusService.initialize();
  }

  void addAnimationValue() {
    if (widget.status.first.userId == UserDetails.uId) {
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


  void startTimer({bool? videoIsActive}) {
    if (isPaused) {
      resumeTimer();
      return;
    }

    timer?.cancel();

    if (widget.status[currentIndex].pathType == 'video') {
      if (widget.status[currentIndex].videoController == null ||
          !widget.status[currentIndex].videoController!.value.isInitialized) {
        return;
      }

      final controller = widget.status[currentIndex].videoController!;
      totalDuration = controller.value.duration.inSeconds.toDouble();
      totalFrames = totalDuration * framesPerSecond;
      startLine = controller.value.position.inSeconds.toDouble() / totalDuration;

      controller.removeListener(_updateProgress);
      controller.addListener(_updateProgress);
    } else {
      totalDuration = 5.0;
      totalFrames = totalDuration * framesPerSecond;
      startLine = 0.0;
      remainingFrames = totalFrames.toInt();

      timer = Timer.periodic(
        Duration(milliseconds: (1000 / framesPerSecond).round()),
            (timer) {
          if (!isPaused && mounted) {
            setState(() {
              startLine += 1.0 / totalFrames;
              remainingFrames--;

              if (startLine >= 1.0) {
                timer.cancel();
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _handleCompletion();
                });
              }
            });
          }
        },
      );
    }
  }

  void _updateProgress() {
    if (!mounted || _isExiting || _isDisposed) return;

    final currentItem = widget.status[currentIndex];

    if (currentItem.pathType == 'video' && currentItem.videoController != null) {
      final controller = currentItem.videoController!;
      final duration = controller.value.duration.inSeconds.toDouble();
      final position = controller.value.position.inSeconds.toDouble();

      if (duration > 0) {
        final newProgress = position / duration;

        if (mounted) {
          setState(() {
            startLine = newProgress;
          });
        }

        if (newProgress >= 1.0) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _handleCompletion();
          });
        }
      }
    }
  }

  void _handleCompletion() async {
    if (_isExiting || _isDisposed) return;
    _isExiting = true;

    try {
      if (currentIndex < widget.status.length - 1) {
        await _switchToNextItem();
      } else {
        await Future.delayed(const Duration(milliseconds: 300));
        await _exitScreen();
      }
    } finally {
      _isExiting = false;
    }
  }

  Future<void> _switchToNextItem() async {
    if (!mounted) return;

    await widget.status[currentIndex].videoController?.pause();

    if (mounted) {
      setState(() {
        currentIndex ++;
        startLine = 0.0;
      });
      startTimer();
    }
  }

  Future<void> _exitScreen() async {
    Navigator.pop(context);
    setState(() async{
      await widget.status[currentIndex].videoController?.pause();
      await widget.status[currentIndex].videoController?.seekTo(Duration.zero);
    });
  }

  void pauseTimer() {
    if (timer != null && timer!.isActive && !isPaused) {
      isPaused = true;
      if (widget.status[currentIndex].pathType == 'video') {
        widget.status[currentIndex].videoController!.pause();
      }
    }
  }

  void resumeTimer() {
    if (isPaused) {
      isPaused = false;
    }
    if (widget.status[currentIndex].pathType == 'video') {
      widget.status[currentIndex].videoController!.play();
    }
  }

  void togglePause() {
    if (isPaused) {
      resumeTimer();
    } else {
      pauseTimer();
    }
  }

  void cancelTimer() {
    timer?.cancel();
    isPaused = false;
    remainingFrames = 0;
  }


  @override
  void dispose() {
    _isDisposed = true;
    _isExiting = true;

    timer?.cancel();
    controller.dispose();

    for (var status in widget.status) {
      try {
        status.videoController?.removeListener(_updateProgress);
        status.videoController?.pause();
        status.videoController?.seekTo(Duration.zero);
      } catch (e) {
        debugPrint('Error disposing video controller: $e');
      }
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        alignment: AlignmentDirectional.bottomEnd,
        children: [
          _buildContent(),
          Row(children: [
            Expanded(
              child: GestureDetector(
                onTap: () {
                  if (currentIndex > 0) {
                    setState(() {
                      if(widget.status[currentIndex].pathType == 'video'){
                        widget.status[currentIndex].videoController!.pause();
                        widget.status[currentIndex].videoController!.seekTo(Duration.zero);
                      }
                      currentIndex --;
                      startLine = 0.0;
                      if(widget.status[currentIndex].pathType == 'video'){
                        widget.status[currentIndex].videoController!.play();
                      }
                    });
                    startTimer();
                  } else {
                    Navigator.pop(context);
                    widget.status[currentIndex].videoController!.pause();
                    widget.status[currentIndex].videoController!.seekTo(Duration.zero);
                  }
                },
                onLongPress: pauseTimer,
                onLongPressUp: resumeTimer,
              ),
            ),
            Expanded(
              child: GestureDetector(
                onTap: () {
                  if (currentIndex < widget.status.length - 1) {
                    setState(() {
                      if(widget.status[currentIndex].pathType == 'video'){
                        widget.status[currentIndex].videoController!.pause();
                        widget.status[currentIndex].videoController!.seekTo(Duration.zero);
                      }
                      currentIndex ++;
                      startLine = 0.0;
                      if(widget.status[currentIndex].pathType == 'video') {
                        widget.status[currentIndex].videoController!.play();
                      }
                    });
                    startTimer();
                  } else {
                    Navigator.pop(context);
                    widget.status[currentIndex].videoController!.pause();
                    widget.status[currentIndex].videoController!.seekTo(Duration.zero);
                  }
                },
                onLongPress: pauseTimer,
                onLongPressUp: resumeTimer,
              ),
            ),
          ]),
          Column(
            children: [
              SizedBox(height: 25.0),
              Row(
                children: List.generate(
                  widget.status.length,
                      (int index) =>
                      stateLine(
                        currentIndex: currentIndex,
                        indexLine: index,
                        startLine: startLine,
                      ),
                ),
              ),
      Padding(
        padding: EdgeInsets.only(
          top: 20.0,
          left: 12.0,
          bottom: 15.0,
          right: 15.0,
        ),
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
                            onTap: () {
                              if (widget.status[currentIndex].userId == UserDetails.uId) {
                                Navigator.pop(context);
                                MainLayoutCubit.get(context).changeIndexScreen(4);
                              }
                              else {
                                navigator(
                                  context,
                                  UserProfile(
                                      userId: widget.status[currentIndex]
                                          .userId!),
                                );
                              }
                            },
                            child: Container(
                              width: 50.0,
                              height: 50.0,
                              child: Image.network(
                                widget.status[currentIndex].userImage!,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) =>
                                    Container(
                                        width: 50.0,
                                        height: 50.0,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(50.0),
                                          border: Border.all(color: Colors.white)
                                        ),
                                        child: Icon(Icons.person, size: 40.0)),
                              ),
                            ),
                          ),
                        ),
                      ),
                      if (widget.status[currentIndex].isOnline == true)
                        Padding(
                          padding: EdgeInsetsDirectional.only(
                            bottom: 3.0,
                            end: 3.0,
                          ),
                          child: CircleAvatar(
                            radius: 5.0,
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
                      onTap: () {
                        if (widget.status[currentIndex].userId ==
                            UserDetails.uId) {
                          Navigator.pop(context);
                          MainLayoutCubit.get(context).changeIndexScreen(4);
                        }
                        else {
                          navigator(
                            context,
                            UserProfile(
                                userId: widget.status[currentIndex].userId!),
                          );
                        }
                      },
                      child: Text(
                        widget.status[currentIndex].userName ?? '',
                        style: TextStyle(
                          fontSize: 20.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                      Row(
                        children: [
                          Text(
                            '${getTimeAgo(widget.status[currentIndex].dateTime!)} . ',
                            style: TextStyle(fontSize: 20.0 * 0.75),
                          ),
                          Icon(
                            map[widget.status[currentIndex].userState],
                            size: 20.0,
                          ),
                        ],
                      ),
                  ],
                ),
              ],
            ),
            if (widget.status[currentIndex].userText?.isNotEmpty ?? false)
              Padding(
                padding: const EdgeInsets.only(top: 8.0, left: 8.0, right: 8.0),
                child: Text(widget.status[currentIndex].userText!),
              ),
          ],
        ),
      )
            ],
          ),
          Positioned(
            top: 55.0,
            right: 0.0,
            child: Column(
              children: [
                IconButton(
                  onPressed: () {
                    setState(() {
                      isOpen = !isOpen;
                      _toggleAnimation(isOpen);
                    });
                    togglePause();
                  },
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
                          widget.status.first.userId == UserDetails.uId ?
                      smallMenu(
                        context: context,
                        buttonName: 'Edit',
                        onPressed: () =>
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    CreatePost(
                                      buttonName: 'Save',
                                      titleName: 'UpdateStatus',
                                      postModel: widget.status[currentIndex],
                                      onPressed: (statusModel) => HomeCubit.get(context)
                                          .insertAndUpdateStatuses(statusModel: statusModel),
                                    ),
                              ),
                            ),
                      ) : SizedBox(),
                      animation.value == value ?
                      smallMenu(
                        context: context,
                        buttonName: 'Delete',
                        onPressed: () async {
                          await showExitDialog(
                              context: context,
                              onPressed: (val) =>
                              val ? widget.onPressed(
                                  widget.status[currentIndex]) : null,
                            type: 'status'
                          );
                        },
                      ) : SizedBox(),
                    ],
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildContent() {
    final currentStatus = widget.status[currentIndex];

    switch (currentStatus.pathType) {
      case 'image':
        return _buildImageContent();
      case 'video':
        return _buildVideoContent(currentStatus);
      default:
        return const SizedBox();
    }
  }

  Widget _buildVideoContent(PostModel postModel) {
    if (postModel.userPost == null || postModel.userPost!.isEmpty) {
      return const Center(child: Text('There is no available video'));
    }

    if (postModel.videoController == null) {
      postModel.videoController =
      VideoPlayerController.network(postModel.userPost!)
        ..initialize()
        ..addListener(_updateProgress);
      return const Center(child: CircularProgressIndicator());
    }

    if (postModel.videoController != null &&
        postModel.videoController!.value.isInitialized) {
      setState(() {
        postModel.videoController!.play();
        startTimer(videoIsActive: true);
      });
    }

    if (!postModel.videoController!.value.isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }

    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context);
        setState(() async {
          await postModel.videoController?.pause();
          await postModel.videoController?.seekTo(Duration.zero);
        });
        return true;
      },
      child: SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: AspectRatio(
          aspectRatio: postModel.videoController!.value.aspectRatio,
          child: VideoPlayer(postModel.videoController!),
        ),
      ),
    );
  }

  Widget _buildImageContent() {
    return SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: Image.network(
          widget.status[currentIndex].userPost!,
          fit: BoxFit.cover,
        ),
    );
  }
}


class HomeState extends StatefulWidget {
  final List<PostModel> state;
  void Function(PostModel) deleteStatus;

  HomeState({
    super.key,
    required this.state,
    required this.deleteStatus,
  });

  @override
  State<HomeState> createState() => _HomeStateState();
}

class _HomeStateState extends State<HomeState> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 3.0),
      child: Column(
        children: [
          Container(
            height: 180.0,
            width: 90.0,
            child: InkWell(
              onTap: () {
                navigator(
                  context,
                  StatusScreen(
                    status: widget.state,
                    onPressed: (object) => widget.deleteStatus(object),
                  ),
                );
              },
              child: Stack(
                children: [
                  widget.state.first.pathType == 'image' ?
                  Container(
                    height: 180.0,
                    width: 90.0,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10.0),
                      border: Border.all(color: Colors.grey, width: 1.0),
                      image: DecorationImage(
                        image: NetworkImage(widget.state.first.userPost ?? ''),
                        fit: BoxFit.cover,
                      ),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black26,
                            blurRadius: 4.0,
                            offset: Offset(2.0, 2.0))
                      ],
                    ),
                  ) : _buildVideoContent(widget.state.first),
                  Positioned(
                      top: 8.0,
                      left: 8.0,
                      child:
                      Container(
                        height: 25.0,
                        width: 25.0,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(50.0),
                          border: Border.all(color: Colors.grey, width: 1.0),
                          image: DecorationImage(
                            image: NetworkImage(
                                widget.state.first.userImage ?? ''),
                            fit: BoxFit.cover,
                          ),
                          boxShadow: [
                            BoxShadow(
                                color: Colors.black26,
                                blurRadius: 4.0,
                                offset: Offset(2.0, 2.0))
                          ],
                        ),
                      )
                  ),
                  Positioned(
                    bottom: 8.0,
                    left: 6.0,
                    child: Container(
                      width: 80.0,
                      child: Text(
                        widget.state.first.userName ?? '',
                        style: TextStyle(
                            overflow: TextOverflow.ellipsis,
                            fontSize: 12.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.white
                        ),
                        maxLines: 2,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildVideoContent(PostModel postModel) {
    if (postModel.userPost == null || postModel.userPost!.isEmpty) {
      return const Center(child: Text('There is no available video'));
    }

    postModel.videoController ??=
    VideoPlayerController.network(postModel.userPost!)
      ..initialize();

    return Container(
      height: 180.0,
      width: 90.0,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.0),
        border: Border.all(color: Colors.grey, width: 1.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 4.0,
            offset: Offset(2.0, 2.0),
          )
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10.0),
        child: AspectRatio(
          aspectRatio: postModel.videoController!.value.aspectRatio,
          child: VideoPlayer(postModel.videoController!),
        ),
      ),
    );
  }
}


Widget stateLine({
  required int currentIndex,
  required int indexLine,
  required double startLine,
}) {
  return Expanded(
    child: Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        height: 2.0,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30.0),
          color: Colors.white.withOpacity(0.5),
        ),
        child: currentIndex == indexLine
            ? CustomPaint(
          size: Size(double.infinity, 2.0),
          painter: StatusLoading(startLine: startLine),
        )
            : SizedBox(),
      ),
    ),
  );
}

class HomeBuilder extends StatefulWidget {
  final List<List<PostModel>> homeStatus;
  final List<PostModel> homeData;
  final void Function(PostModel) deletePost;
  final void Function(PostModel) deleteStatus;
  final Future<void> Function() loadMoreStatus;
  final bool hasMoreStatus;
  final bool hasMorePosts;
  final HomeCubit homeCubit;

  const HomeBuilder({
    required this.homeStatus,
    required this.homeData,
    required this.deletePost,
    required this.deleteStatus,
    required this.loadMoreStatus,
    required this.hasMoreStatus,
    required this.hasMorePosts,
    required this.homeCubit,
    super.key,
  });

  @override
  State<HomeBuilder> createState() => _HomeBuilderState();
}

class _HomeBuilderState extends State<HomeBuilder> with WidgetsBindingObserver {
  final ScrollController _scrollControllerStatus = ScrollController();
  bool _isLoadingStatus = false;
  bool animationToggle = true;

  @override
  void initState() {
    super.initState();
    animationRepeat();
    _scrollControllerStatus.addListener(_onScrollStatus);
    WidgetsBinding.instance.addObserver(this);
  }

  void animationRepeat() {
    Future.delayed(Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() {
          animationToggle = !animationToggle;
          animationRepeat();
        });
      }
    });
  }

  @override
  void dispose() {
    _scrollControllerStatus.dispose();
    _scrollControllerStatus.removeListener(_onScrollStatus);
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }


  void _onScrollStatus() {
    if (_scrollControllerStatus.position.pixels >=
        _scrollControllerStatus.position.maxScrollExtent - 200.0 &&
        !_isLoadingStatus &&
        widget.hasMoreStatus) {
      _loadMoreStatus();
    }
  }

  Future<void> _loadMoreStatus() async {
    if (_isLoadingStatus) return;

    setState(() => _isLoadingStatus = true);
    await widget.loadMoreStatus().whenComplete(() =>
        setState(() => _isLoadingStatus = false)
    );
  }


  @override
  Widget build(BuildContext context) {
    return BlocConsumer<HomeCubit, CubitStates>(
        listener: (context, state) {},
        builder: (context, state) {
          return ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery
                  .of(context)
                  .size
                  .height,
            ),
            child: Column(
              children: [
                // Status Section
                SizedBox(
                  height: 200,
                  child: Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right: 3.0, left: 10.0),
                        child: Container(
                          height: 180.0,
                          width: 90.0,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10.0),
                            border: Border.all(color: Colors.grey, width: 1.0),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black26,
                                blurRadius: 4.0,
                                offset: Offset(2.0, 2.0),
                              )
                            ],
                          ),
                          child: InkWell(
                            onTap: () {
                              navigator(
                                context,
                                CreatePost(
                                    buttonName: 'Publish',
                                    titleName: 'Create status',
                                    onPressed: (statusModel) {
                                      HomeCubit.get(context)
                                          .insertAndUpdateStatuses(
                                          statusModel: statusModel);
                                    }
                                ),
                              );
                            },
                            child: Stack(
                              alignment: AlignmentDirectional.topCenter,
                              children: [
                                Container(
                                  height: 120.0,
                                  width: double.infinity,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(10.0),
                                      topRight: Radius.circular(10.0),
                                    ),
                                    child: UserDetails.image.isNotEmpty ?
                                    Image(
                                      image: NetworkImage(
                                          UserDetails.image),
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error,
                                          stackTrace) {
                                        return Container(color: Colors.grey);
                                      },
                                    ) : Icon(Icons.person, size: 50.0),
                                  ),
                                ),
                                Positioned(
                                  bottom: 45.0,
                                  child: Container(
                                    height: 30.0,
                                    width: 30.0,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(50.0),
                                      color: Colors.blue.shade900,
                                    ),
                                    child: Center(
                                      child: Icon(
                                        Icons.add,
                                        size: 25.0,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: ConditionalBuilder(
                          condition: widget.homeStatus.isNotEmpty,
                          builder: (context) {
                            return ListView.builder(
                              controller: _scrollControllerStatus,
                              scrollDirection: Axis.horizontal,
                              itemCount: widget.homeStatus.length +
                                  (widget.hasMoreStatus ? 1 : 0),
                              itemBuilder: (context, index) {
                                if (index < widget.homeStatus.length) {
                                  return HomeState(
                                    state: widget.homeStatus[index],
                                    deleteStatus: (object) =>
                                        widget.deleteStatus(object),
                                  );
                                } else if (_isLoadingStatus) {
                                  return Padding(padding: EdgeInsets.all(8.0),
                                    child: Container(
                                      height: 180.0,
                                      width: 90.0,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(
                                            10.0),
                                        border: Border.all(
                                            color: Colors.grey.shade400,
                                            width: 1.0),
                                        boxShadow: [
                                          BoxShadow(
                                              color: Colors.black26,
                                              blurRadius: 4.0,
                                              offset: Offset(2.0, 2.0))
                                        ],
                                      ),
                                    ),
                                  );
                                } else {
                                  return SizedBox();
                                }
                              },
                            );
                          },
                          fallback: (context) => _statusesTemplate(),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(height: 1.0, color: Colors.grey),

                // Posts Section
                ConditionalBuilder(
                  condition: widget.homeData.isNotEmpty,
                  builder: (context) {
                    return ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: widget.homeData.length +
                          (widget.hasMorePosts ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index < widget.homeData.length) {
                          return HomeItem(
                            postModel: widget.homeData[index],
                            deletePost: (val) =>
                              val? widget.deletePost(widget.homeData[index]) : null
                          );
                        }
                        else if (state is ListSuccessState){
                          return HomeItem(
                            postModel: widget.homeData[0],
                            deletePost: (val) =>
                                widget.deletePost(widget.homeData[0]),
                          );
                        }
                        else if (widget.hasMorePosts) {
                          return Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Center(child: Text(
                              'Loading more...',
                              style: TextStyle(
                                  color: Colors.blue.shade700
                              ),
                            )),
                          );
                        } else {
                          return const SizedBox();
                        }
                      },
                    );
                  },
                  fallback: (context) => _postsTemplate(),
                ),
              ],
            ),
          );
        });
  }

  Widget _postsTemplate() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(
            top: 20.0,
            left: 12.0,
            bottom: 15.0,
            right: 15.0,
          ),
          child: ClipOval(
            child: Material(
              child: InkWell(
                child: AnimatedContainer(
                  duration: Duration(seconds: 1),
                  curve: Curves.easeInOut,
                  decoration: BoxDecoration(
                      color: Theme.of(context).brightness == Brightness.light ?
                      animationToggle ? Colors.transparent : Colors.black12 :
                      animationToggle ? Colors.transparent : Colors.black87,
                      borderRadius: BorderRadius.circular(50.0),
                      border: Border.all(
                          color: Colors.grey.shade400,
                          width: 1.0),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black26,
                            blurRadius: 4.0

                        )
                      ]),
                  width: 50.0,
                  height: 50.0,
                ),
              ),
            ),
          ),
        ),
        AnimatedContainer(
          duration: Duration(seconds: 1),
          width: double.infinity,
          height: 400.0,
          curve: Curves.easeInOut,
          decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.light ?
              animationToggle ? Colors.transparent : Colors.black12 :
              animationToggle ? Colors.transparent : Colors.black87,
              borderRadius: BorderRadius.circular(8.0),
              border: Border.all(
                  color: Colors.grey.shade400,
                  width: 1.0),
              boxShadow: [
                BoxShadow(
                    color: Colors.black26,
                    blurRadius: 4.0
                )
              ]),
        ),
      ],
    );
  }

  Widget _statusesTemplate() {
    return ListView(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        scrollDirection: Axis.horizontal,
        children: List.generate(10, (index) {
          return Padding(
            padding: const EdgeInsets.symmetric(
                vertical: 10.0, horizontal: 3.0),
            child: Stack(
              children: [
                AnimatedContainer(
                  duration: Duration(seconds: 1),
                  height: 180.0,
                  width: 90.0,
                  curve: Curves.easeInOut,
                  decoration: BoxDecoration(
                    color: Theme.of(context).brightness == Brightness.light ?
                    animationToggle ? Colors.transparent : Colors.black12 :
                    animationToggle ? Colors.transparent : Colors.black87,
                    borderRadius: BorderRadius.circular(10.0),
                    border: Border.all(color: Colors.grey, width: 1.0),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black26,
                          blurRadius: 4.0,
                          offset: Offset(2.0, 2.0))
                    ],
                  ),
                ),
                Positioned(
                  top: 8.0,
                  left: 8.0,
                  child: AnimatedContainer(
                    duration: Duration(seconds: 1),
                    height: 25.0,
                    width: 25.0,
                    curve: Curves.easeInOut,
                    decoration: BoxDecoration(
                      color: Theme.of(context).brightness == Brightness.light ?
                      animationToggle ? Colors.transparent : Colors.black12 :
                      animationToggle ? Colors.transparent : Colors.black87,
                      borderRadius: BorderRadius.circular(50.0),
                      border: Border.all(color: Colors.grey, width: 1.0),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black26,
                            blurRadius: 4.0,
                            offset: Offset(2.0, 2.0))
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        })
    );
  }
}


class StatusLoading extends CustomPainter {
  final double startLine;
  final Paint paintLine = Paint()
    ..color = Colors.white
    ..strokeWidth = 2.0;

  StatusLoading({required this.startLine});

  @override
  void paint(Canvas canvas, Size size) {
    final p1 = Offset(0, size.height / 2);
    final p2 = Offset(startLine * size.width, size.height / 2);
    canvas.drawLine(p1, p2, paintLine);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}