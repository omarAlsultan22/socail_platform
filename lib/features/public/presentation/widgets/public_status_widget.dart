import 'layouts/status_layout.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../../../../../core/di/service _locator.dart';
import 'package:social_app/core/constants/app_sizes.dart';
import 'package:social_app/core/constants/app_colors.dart';
import 'package:social_app/core/constants/app_borders.dart';
import 'package:social_app/core/constants/app_strings.dart';
import 'package:social_app/core/constants/app_paddings.dart';
import 'package:social_app/core/data/models/post_model.dart';
import 'package:social_app/core/data/models/message_result.dart';
import 'package:social_app/core/services/data/session_service.dart';
import 'package:social_app/features/public/data/models/user_details.dart';
import 'package:social_app/core/presentation/widgets/navigation/navigator.dart';


class PublicStateWidget extends StatefulWidget {
  final UserDetails userDetails;
  final MessageResult messageResult;
  final List<PostModel> statusesList;
  final void Function(PostModel) onUpsert;
  final void Function(PostModel) onRemove;

  const PublicStateWidget({
    super.key,
    required this.onUpsert,
    required this.onRemove,
    required this.userDetails,
    required this.statusesList,
    required this.messageResult
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
      padding: AppPaddings.symmetricStatusCard,
      child: Column(
        children: [
          SizedBox(
            height: AppSizes.statusCardHeight,
            width: AppSizes.statusCardWidth,
            child: InkWell(
              onTap: () {
                BuildNavigator.build(
                  context: context,
                  link: StatusLayout(
                      onUpsert: widget.onUpsert,
                      onRemove: widget.onRemove,
                      userDetails: widget.userDetails,
                      statusesList: widget.statusesList,
                      messageResult: widget.messageResult,
                      sessionService: sl<SessionService>()
                  ),
                );
              },
              child: Stack(
                children: [
                  statusModel.pathType == AppStrings.image ?
                  Container(
                    height: AppSizes.statusCardHeight,
                    width: AppSizes.statusCardWidth,
                    decoration: BoxDecoration(
                      borderRadius: AppBorders.borderRadius_10,
                      border: Border.all(color: AppColors.grey, width: 1.0),
                      image: DecorationImage(
                        image: NetworkImage(statusModel.userPost),
                        fit: BoxFit.cover,
                      ),
                      boxShadow: [
                        BoxShadow(
                            color: AppColors.black26,
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
                        height: AppSizes.size25,
                        width: AppSizes.size25,
                        decoration: BoxDecoration(
                          borderRadius: AppBorders.borderRadius_50,
                          border: Border.all(color: AppColors.grey, width: 1.0),
                          image: DecorationImage(
                            image: NetworkImage(
                                widget.userDetails.myImageUrl),
                            fit: BoxFit.cover,
                          ),
                          boxShadow: [
                            BoxShadow(
                                color: AppColors.black26,
                                blurRadius: 4.0,
                                offset: Offset(2.0, 2.0))
                          ],
                        ),
                      )
                  ),
                  Positioned(
                    bottom: 8.0,
                    left: 6.0,
                    child: SizedBox(
                      width: AppSizes.size80,
                      child: Text(
                        widget.userDetails.myName,
                        style: TextStyle(
                            overflow: TextOverflow.ellipsis,
                            fontSize: 12.0,
                            fontWeight: FontWeight.bold,
                            color: AppColors.white
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
    if (postModel.userPostIsEmpty) {
      return Center(child: Text(AppStrings.noVideo));
    }

    postModel.videoController ??=
    VideoPlayerController.network(postModel.userPost!)
      ..initialize();

    return Container(
      height: AppSizes.statusCardHeight,
      width: AppSizes.statusCardWidth,
      decoration: BoxDecoration(
        borderRadius: AppBorders.borderRadius_10,
        border: Border.all(color: AppColors.grey, width: 1.0),
        boxShadow: [
          BoxShadow(
            color: AppColors.black26,
            blurRadius: 4.0,
            offset: Offset(2.0, 2.0),
          )
        ],
      ),
      child: ClipRRect(
        borderRadius: AppBorders.borderRadius_10,
        child: AspectRatio(
          aspectRatio: postModel.aspectRatio,
          child: VideoPlayer(postModel.videoController!),
        ),
      ),
    );
  }
}