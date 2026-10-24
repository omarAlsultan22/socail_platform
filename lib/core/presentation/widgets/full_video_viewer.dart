import 'video_time_indicator.dart';
import 'package:flutter/material.dart';
import '../../data/models/post_model.dart';
import 'package:video_player/video_player.dart';
import 'package:social_app/core/constants/app_sizes.dart';
import 'package:social_app/core/constants/app_colors.dart';
import 'package:social_app/core/constants/app_paddings.dart';
import 'package:social_app/core/presentation/widgets/states/loading_state_widget.dart';


class FullVideoViewer extends StatefulWidget {
  final PostModel postModel;

  const FullVideoViewer({
    super.key,
    required this.postModel,
  });

  @override
  State<FullVideoViewer> createState() => _FullVideoViewerState();
}

class _FullVideoViewerState extends State<FullVideoViewer> {
  bool _isInitialized = false;
  VideoPlayerController? _controller;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    if (widget.postModel.file == null) return;

    _controller = VideoPlayerController.network(widget.postModel.userPost!);
    await _controller!.initialize();
    await _controller!.play();

    _controller!.addListener(_onVideoUpdate);

    if (mounted) {
      setState(() {
        _isInitialized = true;
      });
    }
  }

  void _onVideoUpdate() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _controller?.removeListener(_onVideoUpdate);
    _controller?.pause();
    _controller?.dispose();
    _controller = null;
    super.dispose();
  }

  void _togglePlayPause() {
    if (_controller == null) return;
    setState(() {
      if (_controller!.value.isPlaying) {
        _controller!.pause();
      } else {
        _controller!.play();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized || _controller == null) {
      return LoadingStateWidget();
    }

    final isPlaying = _controller!.value.isPlaying;

    return Dialog(
      backgroundColor: AppColors.black,
      insetPadding: AppPaddings.all20,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AspectRatio(
            aspectRatio: _controller!.value.aspectRatio,
            child: GestureDetector(
              onTap: _togglePlayPause,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  VideoPlayer(_controller!),
                  if (!isPlaying)
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.black30,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.play_arrow,
                        size: AppSizes.xl,
                        color: AppColors.white,
                      ),
                    ),
                ],
              ),
            ),
          ),
          Padding(
            padding: AppPaddings.symmetricHorizontal16Vertical8,
            child: Column(
              children: [
                VideoProgressIndicator(
                  _controller!,
                  allowScrubbing: true,
                  padding: AppPaddings.symmetricVertical8,
                  colors: const VideoProgressColors(
                    playedColor: AppColors.primaryBlue,
                    bufferedColor: AppColors.grey,
                    backgroundColor: AppColors.grey,
                  ),
                ),
                VideoTimeIndicator(
                  position: _controller!.value.position,
                  duration: _controller!.value.duration,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}