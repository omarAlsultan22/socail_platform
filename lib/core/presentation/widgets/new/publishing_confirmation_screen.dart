import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:video_player/video_player.dart';


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
    _videoController =
        widget.videoController ?? VideoPlayerController.file(widget.file);
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
                      _videoController.seekTo(
                          Duration(milliseconds: newValue.round()));
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
                    color: Theme
                        .of(context)
                        .brightness == Brightness.light
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
  /reuse
  String _formatDuration(Duration d) {
    return '${d.inMinutes}:${(d.inSeconds % 60).toString().padLeft(2, '0')}';
  }
}