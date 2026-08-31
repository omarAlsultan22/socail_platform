import 'video_time_indicator.dart';
import 'package:flutter/material.dart';
import '../../../data/models/post_model.dart';
import 'package:video_player/video_player.dart';


class FullVideoViewer {
  static Future<void> show({
    required PostModel postModel,
    required BuildContext context,
    VideoPlayerController? fullScreenVideoController,
  }) async {
    if (postModel.file == null) return;

    fullScreenVideoController =
        VideoPlayerController.network(postModel.userPost!);
    await fullScreenVideoController.initialize();
    fullScreenVideoController.play();

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            fullScreenVideoController!.addListener(() {
              setState(() {});
            });

            return WillPopScope(
              onWillPop: () async {
                await fullScreenVideoController!.pause();
                await fullScreenVideoController!.dispose();
                fullScreenVideoController = null;
                return true;
              },
              child: Dialog(
                backgroundColor: Colors.black,
                insetPadding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AspectRatio(
                      aspectRatio: fullScreenVideoController!.value.aspectRatio,
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            if (fullScreenVideoController!.value.isPlaying) {
                              fullScreenVideoController!.pause();
                            } else {
                              fullScreenVideoController!.play();
                            }
                          });
                        },
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            VideoPlayer(fullScreenVideoController!),
                            if (!fullScreenVideoController!.value.isPlaying)
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
                            fullScreenVideoController!,
                            allowScrubbing: true,
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            colors: const VideoProgressColors(
                              playedColor: Colors.blue,
                              bufferedColor: Colors.grey,
                              backgroundColor: Colors.grey,
                            ),
                          ),
                          VideoTimeIndicator(
                            position: fullScreenVideoController!.value.position,
                            duration: fullScreenVideoController!.value.duration,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}