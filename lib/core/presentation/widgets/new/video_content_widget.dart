import 'package:flutter/material.dart';
import 'package:social_app/core/presentation/widgets/new/video_time_indicator.dart';
import '../../../data/models/post_model.dart';
import 'package:video_player/video_player.dart';
import 'package:social_app/core/presentation/widgets/new/full_video_viewer.dart';


class VideoContentWidget extends StatefulWidget {
  final PostModel postModel;
  final BuildContext context;
  final VideoPlayerController? fullScreenVideoController;
  final double? width;
  final double? height;
  const VideoContentWidget({
    required this.postModel,
    required this.context,
    required this.fullScreenVideoController,
    this.width,
    this.height,
    super.key});

  @override
  State<VideoContentWidget> createState() => _buildVideoContentState();
}

class _buildVideoContentState extends State<VideoContentWidget> {
  @override
  Widget build(BuildContext context) {
    if (widget.postModel.userPost == null ||
        widget.postModel.userPost!.isEmpty) {
      return Container(
        height: widget.height ?? 400.0,
        width: widget.width ?? double.infinity,
        color: Colors.grey,
        child: Center(child: Text('There is no available video')),
      );
    }

    widget.postModel.videoController ??=
    VideoPlayerController.network(widget.postModel.userPost!)
      ..initialize().then((_) {
        if (mounted) setState(() {});
      });
    return GestureDetector(
      onTap: () =>
          FullVideoViewer.show(
              context: context,
              postModel: widget.postModel,
              fullScreenVideoController: widget.fullScreenVideoController
          ),
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