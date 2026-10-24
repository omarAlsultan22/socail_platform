import 'package:flutter/material.dart';
import 'package:social_app/core/constants/app_colors.dart';


class VideoTimeIndicator extends StatelessWidget {
  final Duration position;
  final Duration duration;

  const VideoTimeIndicator({
    required this.position,
    required this.duration,
    super.key,
  });

  static const TextStyle _timeStyle = TextStyle(
    color: AppColors.white,
    fontSize: 12,
  );

  @override
  Widget build(BuildContext context) {

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
          style: _timeStyle,
        ),
        Text(
          '$totalMinutes:$totalSeconds',
          style: _timeStyle,
        ),
      ],
    );
  }
}