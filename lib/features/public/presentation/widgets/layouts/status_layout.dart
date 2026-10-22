import 'dart:async';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../../../../../core/di/service _locator.dart';
import 'package:social_app/core/utils/time_ago_helper.dart';
import 'package:social_app/core/data/models/post_model.dart';
import 'package:social_app/core/data/models/message_result.dart';
import 'package:social_app/core/services/data/session_service.dart';
import 'package:social_app/core/helpers/friend_profile_navigator.dart';
import '../../../../../core/presentation/mixins/more_options_mixin.dart';
import 'package:social_app/features/public/data/models/user_details.dart';
import '../../../../../core/services/domain/i_online_status_service.dart';
import 'package:social_app/features/public/constants/public_constants.dart';
import 'package:social_app/features/public/presentation/widgets/state_line_widget.dart';


class StatusLayout extends StatefulWidget {
  final UserDetails userDetails;
  final MessageResult messageResult;
  final List<PostModel> statusesList;
  final SessionService sessionService;
  final void Function(PostModel) onUpsert;
  final void Function(PostModel) onRemove;

  const StatusLayout({
    super.key,
    required this.onUpsert,
    required this.onRemove,
    required this.userDetails,
    required this.statusesList,
    required this.messageResult,
    required this.sessionService,
  });

  @override
  State<StatusLayout> createState() => _StatusLayoutState();
}

class _StatusLayoutState extends State<StatusLayout> with SingleTickerProviderStateMixin, MoreOptionsMixin<StatusLayout> {

  // Values
  int timeLeft = 2;
  int currentIndex = 0;
  int remainingFrames = 0;

  bool isPaused = false;
  bool _isExiting = false;
  bool _isDisposed = false;

  double startLine = 0.0;
  double totalDuration = 5.0;
  static double framesPerSecond = 60.0;
  double totalFrames = 5.0 * framesPerSecond;

  // Timer
  Timer? _timer;

  // Status
  late PostModel _firstStatus;
  late PostModel _currentStatus;

  // Service
  late IOnlineStatusService _onlineStatusService;

  @override
  String get postType => 'status';

  @override
  String get titleName => 'UpdateStatus';

  @override
  PostModel get postModel => _firstStatus;

  @override
  UserDetails get userDetails => widget.userDetails;

  @override
  MessageResult get messageResult => widget.messageResult;

  @override
  void Function(PostModel)? get onRemove => widget.onRemove;

  @override
  void Function(PostModel) get onUpsert => widget.onUpsert;

  @override
  SessionService get sessionService => widget.sessionService;

  @override
  void initState() {
    super.initState();
    _firstStatus = widget.statusesList.first;
    _currentStatus = widget.statusesList[currentIndex];
    _onlineStatusService = sl<IOnlineStatusService>();
    _initUserState();
    startTimer();
  }

  Future<void> _initUserState() async {
    _onlineStatusService.initialize();
  }

  void startTimer({bool? videoIsActive}) {
    if (isPaused) {
      resumeTimer();
      return;
    }

    _timer?.cancel();

    if (_currentStatus.pathType == 'video') {
      if (_currentStatus.videoController == null ||
          !_currentStatus.videoIsInitialized) {
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

      _timer = Timer.periodic(
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

    final currentStatus = widget.statusesList[currentIndex];

    if (currentStatus.pathType == 'video' &&
        currentStatus.videoController != null) {
      final controller = currentStatus.videoController!;
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

    await _currentStatus.pauseVideo;

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
      await _currentStatus.pauseVideo;
      await _currentStatus.seekToVideo;
    });
  }

  void pauseTimer() {
    if (_timer != null && _timer!.isActive && !isPaused) {
      isPaused = true;
      if (_currentStatus.pathType == 'video') {
        _currentStatus.pauseVideo;
      }
    }
  }

  void resumeTimer() {
    if (isPaused) {
      isPaused = false;
    }
    if (_currentStatus.pathType == 'video') {
      _currentStatus.playVideo;
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
    _timer?.cancel();
    isPaused = false;
    remainingFrames = 0;
  }

  @override
  void dispose() {
    _isDisposed = true;
    _isExiting = true;

    _timer?.cancel();

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
                onTap: () async {
                  if (currentIndex > 0) {
                    setState(() async {
                      if (_currentStatus.pathType == 'video') {
                        await _currentStatus.pauseVideo;
                        await _currentStatus.seekToVideo;
                      }
                      currentIndex --;
                      startLine = 0.0;
                      if (_currentStatus.pathType == 'video') {
                        await _currentStatus.playVideo;
                      }
                    });
                    startTimer();
                  } else {
                    Navigator.pop(context);
                    await _currentStatus.pauseVideo;
                    await _currentStatus.seekToVideo;
                  }
                },
                onLongPress: pauseTimer,
                onLongPressUp: resumeTimer,
              ),
            ),
            Expanded(
              child: GestureDetector(
                onTap: () async {
                  if (currentIndex < widget.statusesList.length - 1) {
                    setState(() async {
                      if (_currentStatus.pathType == 'video') {
                        await _currentStatus.pauseVideo;
                        await _currentStatus.seekToVideo;
                      }
                      currentIndex ++;
                      startLine = 0.0;
                      if (_currentStatus.pathType == 'video') {
                        await _currentStatus.playVideo;
                      }
                    });
                    startTimer();
                  } else {
                    Navigator.pop(context);
                    await _currentStatus.pauseVideo;
                    await _currentStatus.seekToVideo;
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
                          indexLine: index,
                          startLine: startLine,
                          currentIndex: currentIndex
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
                                    onTap: () =>
                                        FriendProfileNavigator.handle(
                                            context: context,
                                            modelUserId: _currentStatus.myId,
                                            sessionService: widget
                                                .sessionService
                                        ),
                                    child: SizedBox(
                                      width: 50.0,
                                      height: 50.0,
                                      child: Image.network(
                                        widget.userDetails.myImageUrl,
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
                              if (_currentStatus.meIsOnline == true)
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
                              onTap: () =>
                                  FriendProfileNavigator.handle(
                                      context: context,
                                      modelUserId: _currentStatus.myId,
                                      sessionService: widget.sessionService
                                  ),
                              child: Text(
                                widget.userDetails.myName,
                                style: TextStyle(
                                  fontSize: 20.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Row(
                              children: [
                                Text(
                                  '${TimeAgoHelper.getTimeAgo(
                                      widget.statusesList[currentIndex]
                                          .myDateTime!)} . ',
                                  style: TextStyle(fontSize: 20.0 * 0.75),
                                ),
                                Icon(
                                  PublicConstants.getStatus(
                                      widget.statusesList[currentIndex]
                                          .myState),
                                  size: 20.0,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                    if (_currentStatus.userTextIsEmpty)
                      Padding(
                        padding: const EdgeInsets.only(
                            top: 8.0, left: 8.0, right: 8.0),
                        child: Text(_currentStatus.userText!),
                      ),
                  ],
                ),
              )
            ],
          ),
          buildMoreOptions()
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
    if (postModel.userPostIsEmpty) {
      return const Center(child: Text('There is no available video'));
    }

    if (postModel.videoController == null) {
      postModel.videoController =
      VideoPlayerController.network(postModel.userPost)
        ..initialize()
        ..addListener(_updateProgress);
      return const Center(child: CircularProgressIndicator());
    }

    if (postModel.videoController != null &&
        postModel.videoIsInitialized) {
      setState(() {
        postModel.playVideo;
        startTimer(videoIsActive: true);
      });
    }

    if (!postModel.videoIsInitialized) {
      return const Center(child: CircularProgressIndicator());
    }

    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context);
        setState(() async {
          await postModel.pauseVideo;
          await postModel.seekToVideo;
        });
        return true;
      },
      child: SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: AspectRatio(
          aspectRatio: postModel.aspectRatio,
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
        _currentStatus.userPost,
        fit: BoxFit.cover,
      ),
    );
  }
}