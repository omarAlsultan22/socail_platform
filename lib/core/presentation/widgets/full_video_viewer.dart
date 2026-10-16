import 'video_time_indicator.dart';
import 'package:flutter/material.dart';
import '../../data/models/post_model.dart';
import 'package:video_player/video_player.dart';


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
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    return Dialog(
      backgroundColor: Colors.black,
      insetPadding: const EdgeInsets.all(20),
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
                  if (!_controller!.value.isPlaying)
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
                  _controller!,
                  allowScrubbing: true,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  colors: const VideoProgressColors(
                    playedColor: Colors.blue,
                    bufferedColor: Colors.grey,
                    backgroundColor: Colors.grey,
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