import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../../../../core/di/service _locator.dart';
import '../../../../core/data/models/post_model.dart';
import 'package:social_app/core/constants/app_sizes.dart';
import 'package:social_app/core/constants/app_colors.dart';
import 'package:social_app/core/constants/app_strings.dart';
import 'package:social_app/core/data/models/message_result.dart';
import 'package:social_app/core/services/data/session_service.dart';
import 'package:social_app/features/public/data/models/user_details.dart';
import 'package:social_app/core/presentation/screens/view_post_screen.dart';


class VideoContentWidget extends StatefulWidget {
  final double? width;
  final double? height;
  final PostModel postModel;
  final UserDetails userDetails;
  final MessageResult messageResult;
  final void Function(PostModel) onAdd;
  final void Function(PostModel) onUpsert;
  final void Function(PostModel)? onRemove;
  final void Function(bool, PostModel) onToggle;
  const VideoContentWidget({
    super.key,
    this.width,
    this.height,
    this.onRemove,
    required this.onAdd,
    required this.onUpsert,
    required this.onToggle,
    required this.postModel,
    required this.userDetails,
    required this.messageResult,
  });

  @override
  State<VideoContentWidget> createState() => _buildVideoContentState();
}

class _buildVideoContentState extends State<VideoContentWidget> {
  @override
  Widget build(BuildContext context) {
    if (widget.postModel.userPostIsEmpty) {
      return Container(
        height: widget.height ?? AppSizes.size400,
        width: widget.width ?? double.infinity,
        color: AppColors.grey,
        child: Center(child: Text(AppStrings.noVideo)),
      );
    }

    widget.postModel.videoController ??=
    VideoPlayerController.network(widget.postModel.userPost)
      ..initialize().then((_) {
        if (mounted) setState(() {});
      });
    return GestureDetector(
      onTap: () =>
          ViewPostScreen(
              onAdd: widget.onAdd,
              onUpsert: widget.onUpsert,
              onRemove: widget.onRemove,
              onToggle: widget.onToggle,
              postModel: widget.postModel,
              userDetails: widget.userDetails,
              messageResult: widget.messageResult,
              sessionService: sl<SessionService>()
          ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            height: widget.height ?? AppSizes.size400,
            width: widget.width ?? double.infinity,
            child: AspectRatio(
              aspectRatio: widget.postModel.videoController!.value.aspectRatio,
              child: VideoPlayer(widget.postModel.videoController!),
            ),
          ),
          if (!widget.postModel.videoController!.value.isPlaying)
            Container(
              decoration: BoxDecoration(
                color: AppColors.black30,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                  Icons.play_arrow, size: AppSizes.xl, color: AppColors.white
              ),
            ),
        ],
      ),
    );
  }
}