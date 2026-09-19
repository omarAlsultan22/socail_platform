import 'dart:async';
import 'package:flutter/material.dart';
import '../../cubits/public_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:video_player/video_player.dart';
import '../../../../../core/di/service _locator.dart';
import '../../../data/services/online_status_service.dart';
import 'package:social_app/core/utils/time_ago_helper.dart';
import 'package:social_app/core/data/models/post_model.dart';
import 'package:social_app/core/services/session_service.dart';
import '../../../../profile/presentation/screens/friend_profile_screen.dart';
import 'package:social_app/features/public/constants/public_constants.dart';
import 'package:social_app/core/presentation/screens/create_post_screen.dart';
import 'package:social_app/features/main/presentation/cubits/main_cubit.dart';
import 'package:social_app/core/presentation/widgets/navigation/navigator.dart';
import 'package:social_app/core/presentation/widgets/new/small_menu_widget.dart';
import 'package:social_app/core/presentation/widgets/new/exit_dialog_helper.dart';
import 'package:social_app/features/public/presentation/widgets/state_line_widget.dart';

/finish rest of
class PublicLayout extends StatefulWidget {
  final List<PostModel> statusesList;
  final SessionService sessionService;

  const PublicLayout({
    super.key,
    required this.statusesList,
    required this.sessionService
  });

  @override
  State<PublicLayout> createState() => _PublicLayoutState();
}

class _PublicLayoutState extends State<PublicLayout> with TickerProviderStateMixin {

  int timeLeft = 2;
  int currentIndex = 0;
  int remainingFrames = 0;

  bool isPaused = false;
  bool isOpen = false;
  bool _isExiting = false;
  bool _isDisposed = false;

  double value = 35.0;
  double startLine = 0.0;
  double totalDuration = 5.0;
  static double framesPerSecond = 60.0;
  double totalFrames = 5.0 * framesPerSecond;

  late PostModel statusModel;

  late MainCubit _mainCubit;
  late PublicCubit _publicCubit;

  Timer? timer;
  late Animation<double> animation;
  late AnimationController controller;
  final onlineStatusService = sl<OnlineStatusService>();

  @override
  void initState() {
    super.initState();
    statusModel = widget.statusesList.first;
    _cubitsInitialization();
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

  void _cubitsInitialization(){
    _mainCubit = context.read<MainCubit>();
    _publicCubit = context.read<PublicCubit>();
  }

  Future<void> _initUserState() async {
    onlineStatusService.initialize();
  }

  void addAnimationValue() {
    if (statusModel.userId == widget.sessionService.currentUid) {
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

    if (widget.statusesList[currentIndex].pathType == 'video') {
      if (widget.statusesList[currentIndex].videoController == null ||
          !widget.statusesList[currentIndex].videoController!.value.isInitialized) {
        return;
      }

      final controller = widget.statusesList[currentIndex].videoController!;
      totalDuration = controller.value.duration.inSeconds.toDouble();
      totalFrames = totalDuration * framesPerSecond;
      startLine =
          controller.value.position.inSeconds.toDouble() / totalDuration;

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

    final currentItem = widget.statusesList[currentIndex];

    if (currentItem.pathType == 'video' &&
        currentItem.videoController != null) {
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
      if (currentIndex < widget.statusesList.length - 1) {
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

    await widget.statusesList[currentIndex].videoController?.pause();

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
    setState(() async {
      await widget.statusesList[currentIndex].videoController?.pause();
      await widget.statusesList[currentIndex].videoController?.seekTo(Duration.zero);
    });
  }

  void pauseTimer() {
    if (timer != null && timer!.isActive && !isPaused) {
      isPaused = true;
      if (widget.statusesList[currentIndex].pathType == 'video') {
        widget.statusesList[currentIndex].videoController!.pause();
      }
    }
  }

  void resumeTimer() {
    if (isPaused) {
      isPaused = false;
    }
    if (widget.statusesList[currentIndex].pathType == 'video') {
      widget.statusesList[currentIndex].videoController!.play();
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

  void _changeScreen(){
    if (widget.statusesList[currentIndex].userId ==
        widget.sessionService.currentUid) {
      Navigator.pop(context);
      _mainCubit.changeIndexScreen(4);
    }
    else {
      BuildNavigator.build(
        context: context,
        link: FriendProfileScreen(
            userId: widget.statusesList[currentIndex]
                .userId!),
      );
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    _isExiting = true;

    timer?.cancel();
    controller.dispose();

    for (var status in widget.statusesList) {
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
                      if (widget.statusesList[currentIndex].pathType == 'video') {
                        widget.statusesList[currentIndex].videoController!.pause();
                        widget.statusesList[currentIndex].videoController!.seekTo(
                            Duration.zero);
                      }
                      currentIndex --;
                      startLine = 0.0;
                      if (widget.statusesList[currentIndex].pathType == 'video') {
                        widget.statusesList[currentIndex].videoController!.play();
                      }
                    });
                    startTimer();
                  } else {
                    Navigator.pop(context);
                    widget.statusesList[currentIndex].videoController!.pause();
                    widget.statusesList[currentIndex].videoController!.seekTo(
                        Duration.zero);
                  }
                },
                onLongPress: pauseTimer,
                onLongPressUp: resumeTimer,
              ),
            ),
            Expanded(
              child: GestureDetector(
                onTap: () {
                  if (currentIndex < widget.statusesList.length - 1) {
                    setState(() {
                      if (widget.statusesList[currentIndex].pathType == 'video') {
                        widget.statusesList[currentIndex].videoController!.pause();
                        widget.statusesList[currentIndex].videoController!.seekTo(
                            Duration.zero);
                      }
                      currentIndex ++;
                      startLine = 0.0;
                      if (widget.statusesList[currentIndex].pathType == 'video') {
                        widget.statusesList[currentIndex].videoController!.play();
                      }
                    });
                    startTimer();
                  } else {
                    Navigator.pop(context);
                    widget.statusesList[currentIndex].videoController!.pause();
                    widget.statusesList[currentIndex].videoController!.seekTo(
                        Duration.zero);
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
                  widget.statusesList.length,
                      (int index) =>
                      StateLineWidget(
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
                                    onTap: _changeScreen,
                                    child: SizedBox(
                                      width: 50.0,
                                      height: 50.0,
                                      child: Image.network(
                                        widget.statusesList[currentIndex].userImage!,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) =>
                                            Container(
                                                width: 50.0,
                                                height: 50.0,
                                                decoration: BoxDecoration(
                                                    borderRadius: BorderRadius
                                                        .circular(50.0),
                                                    border: Border.all(
                                                        color: Colors.white)
                                                ),
                                                child: Icon(
                                                    Icons.person, size: 40.0)),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              if (widget.statusesList[currentIndex].isOnline == true)
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
                              onTap: _changeScreen,
                              child: Text(
                                widget.statusesList[currentIndex].userName ?? '',
                                style: TextStyle(
                                  fontSize: 20.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Row(
                              children: [
                                Text(
                                  '${TimeAgoHelper.getTimeAgo(widget.statusesList[currentIndex]
                                      .dateTime!)} . ',
                                  style: TextStyle(fontSize: 20.0 * 0.75),
                                ),
                                Icon(
                                  PublicConstants.getStatus(widget.statusesList[currentIndex]
                                      .userState),
                                  size: 20.0,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                    if (widget.statusesList[currentIndex].userText?.isNotEmpty ??
                        false)
                      Padding(
                        padding: const EdgeInsets.only(
                            top: 8.0, left: 8.0, right: 8.0),
                        child: Text(widget.statusesList[currentIndex].userText!),
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
                          statusModel.userId ==
                              widget.sessionService.currentUid ?
                      SmallMenuWidget(
                        context: context,
                        buttonName: 'Edit',
                        onPressed: () async =>
                            BuildNavigator.build(context: context,
                                    link: CreatePostScreen(
                                      buttonName: 'Save',
                                      titleName: 'UpdateStatus',
                                      postModel: widget.statusesList[currentIndex],
                                      onPressed: (statusModel) =>
                                          _publicCubit.insertAndUpdateStatuses(
                                              statusModel: statusModel),
                                      uId: widget.sessionService.currentUid,
                                    ),
                              ),
                      ) : SizedBox(),
                      animation.value == value ?
                      SmallMenuWidget(
                        context: context,
                        buttonName: 'Delete',
                        onPressed: () async {
                          await ExitDialogHelper.showExitDialog(
                              context: context,
                              onPressed: (val) {
                                if (!val) return;
                                _publicCubit.deleteStatus(statusModel: widget.statusesList[currentIndex]);
                              },
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
    final currentStatus = widget.statusesList[currentIndex];

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
    if (postModel.userPost == null || postModel.userPostIsEmpty) {
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
        widget.statusesList[currentIndex].userPost!,
        fit: BoxFit.cover,
      ),
    );
  }
}