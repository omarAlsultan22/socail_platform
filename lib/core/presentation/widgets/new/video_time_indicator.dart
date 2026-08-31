import 'package:flutter/material.dart';
import 'package:social_app/core/presentation/widgets/new/video_content_widget.dart';


class VideoTimeIndicator extends StatelessWidget {
  final Duration position;
  final Duration duration;

  const VideoTimeIndicator({
    required this.position,
    required this.duration,
    super.key,
  });

  @override
  Widget build(BuildContext context) {

    /reusablity
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
          style: const TextStyle(color: Colors.white, fontSize: 12),
        ),
        Text(
          '$totalMinutes:$totalSeconds',
          style: const TextStyle(color: Colors.white, fontSize: 12),
        ),
      ],
    );
  }
}