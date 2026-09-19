import 'layouts/public_layout.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../../../../../core/di/service _locator.dart';
import 'package:social_app/core/data/models/post_model.dart';
import 'package:social_app/core/services/session_service.dart';
import 'package:social_app/core/presentation/widgets/navigation/navigator.dart';


class PublicStateWidget extends StatefulWidget {
  final List<PostModel> statusesList;

  const PublicStateWidget({
    super.key,
    required this.statusesList,
  });

  @override
  State<PublicStateWidget> createState() => _PublicStateWidgetState();
}

class _PublicStateWidgetState extends State<PublicStateWidget> {
  late PostModel statusModel;

  @override
  void initState() {
    statusModel = widget.statusesList.first;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 3.0),
      child: Column(
        children: [
          Container(
            height: 180.0,
            width: 90.0,
            child: InkWell(
              onTap: () {
                BuildNavigator.build(
                  context: context,
                  link: PublicLayout(
                    statusesList: widget.statusesList,
                    sessionService: sl<SessionService>(),
                  ),
                );
              },
              child: Stack(
                children: [
                  statusModel.pathType == 'image' ?
                  Container(
                    height: 180.0,
                    width: 90.0,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10.0),
                      border: Border.all(color: Colors.grey, width: 1.0),
                      image: DecorationImage(
                        image: NetworkImage(statusModel.userPost ?? ''),
                        fit: BoxFit.cover,
                      ),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black26,
                            blurRadius: 4.0,
                            offset: Offset(2.0, 2.0))
                      ],
                    ),
                  ) : _buildVideoContent(statusModel),
                  Positioned(
                      top: 8.0,
                      left: 8.0,
                      child:
                      Container(
                        height: 25.0,
                        width: 25.0,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(50.0),
                          border: Border.all(color: Colors.grey, width: 1.0),
                          image: DecorationImage(
                            image: NetworkImage(
                                statusModel.userImage ?? ''),
                            fit: BoxFit.cover,
                          ),
                          boxShadow: [
                            BoxShadow(
                                color: Colors.black26,
                                blurRadius: 4.0,
                                offset: Offset(2.0, 2.0))
                          ],
                        ),
                      )
                  ),
                  Positioned(
                    bottom: 8.0,
                    left: 6.0,
                    child: Container(
                      width: 80.0,
                      child: Text(
                        statusModel.userName ?? '',
                        style: TextStyle(
                            overflow: TextOverflow.ellipsis,
                            fontSize: 12.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.white
                        ),
                        maxLines: 2,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildVideoContent(PostModel postModel) {
    if (postModel.userPost == null || postModel.userPost!.isEmpty) {
      return const Center(child: Text('There is no available video'));
    }

    postModel.videoController ??=
    VideoPlayerController.network(postModel.userPost!)
      ..initialize();

    return Container(
      height: 180.0,
      width: 90.0,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.0),
        border: Border.all(color: Colors.grey, width: 1.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 4.0,
            offset: Offset(2.0, 2.0),
          )
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10.0),
        child: AspectRatio(
          aspectRatio: postModel.aspectRatio,
          child: VideoPlayer(postModel.videoController!),
        ),
      ),
    );
  }
}