import 'package:flutter/material.dart';
import '../../data/models/post_model.dart';
import '../screens/create_post_screen.dart';
import '../widgets/icon_button_widget.dart';
import '../widgets/navigation/navigator.dart';
import 'package:social_app/core/constants/app_colors.dart';
import 'package:social_app/core/constants/app_spaces.dart';
import 'package:social_app/core/constants/app_borders.dart';
import 'package:social_app/core/constants/app_strings.dart';
import 'package:social_app/core/constants/app_paddings.dart';
import 'package:social_app/core/presentation/mixins/post_context.dart';
import 'package:social_app/core/presentation/widgets/full_video_viewer.dart';
import '../../../features/interactions/likes/presentation/screens/likes_screen.dart';
import '../../../features/interactions/shares/presentation/screens/shares_screen.dart';
import '../../../features/interactions/comments/presentation/screens/comments_screen.dart';


mixin PostComponentsMixin<T extends StatefulWidget> on State<T> implements PostContext{
  //Getters
  String? get userId;

  void Function(PostModel) get onAdd;

  void Function(bool, PostModel) get onToggle;

  late int likes;
  late int shares;
  late int comments;
  bool isActive = false;

  @override
  void initState() {
    super.initState();
    isActive = postModel.hasMeLiked;
    likes = postModel.likesNumber ?? 0;
    shares = postModel.sharesNumber ?? 0;
    comments = postModel.commentsNumber ?? 0;
  }

  void likeToggle() {
    setState(() {
      isActive = !isActive;
      likes += isActive ? 1 : -1;
    });
    onToggle(isActive, postModel);
  }

  Widget buildContent(Widget imageContentWidget) {
    switch (postModel.pathType) {
      case AppStrings.image:
        return imageContentWidget;
      case AppStrings.video:
        return FullVideoViewer(postModel: postModel);
      default:
        return SizedBox();
    }
  }

  Widget interactionsFeedBack() {
    return Padding(
        padding: AppPaddings.symmetricVertical10,
        child: Container(
            decoration: BoxDecoration(
              borderRadius: AppBorders.borderRadius_10,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (likes > 0)
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () =>
                            BuildNavigator.build(
                              context: context,
                              link: LikesScreen(
                                userId: userId,
                                docId: postModel.myDocId,
                              ),
                            ),
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppColors.red,
                            borderRadius: AppBorders.borderRadius_50,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(3.0),
                            child: Icon(
                              Icons.favorite,
                              size: 15,
                              color: AppColors.white,
                            ),
                          ),
                        ),
                      ),
                      AppSpaces.horizontal_5,
                      Text(likes.toString()),
                    ],
                  ),

                Row(
                  children: [
                    if (comments > 0)
                      GestureDetector(
                        onTap: () =>
                            BuildNavigator.build(
                              context: context,
                              link: CommentsScreen(
                                  userId: userId,
                                  docId: postModel.myDocId
                              ),
                            ),
                        child: Padding(
                          padding: AppPaddings.onlyRight15,
                          child: Text('${comments.toString()} comments'),
                        ),
                      ),
                    if (shares > 0)
                      GestureDetector(
                        onTap: () =>
                            BuildNavigator.build(
                              context: context,
                              link: SharesScreen(
                                  userId: userId,
                                  docId: postModel.myDocId
                              ),
                            ),
                        child: Text('${shares.toString()} shares'),
                      ),
                  ],
                ),
              ],
            )
        )
    );
  }

  Widget iconsInteractions() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        IconButtonWidget(
          onPressed: likeToggle,
          icon: Icon(isActive ? Icons.favorite : Icons.favorite_border),
          tooltip: 'Like',
        ),
        IconButton(
          onPressed: () {
            BuildNavigator.build(
              context: context,
              link: CommentsScreen(
                  userId: userId,
                  docId: postModel.myDocId
              ),
            );
          },
          icon: Icon(Icons.comment_outlined),
          tooltip: 'Comment',
        ),
        IconButtonWidget(
          onPressed: () {
            BuildNavigator.build(
              context: context,
              link: CreatePostScreen(
                  titleName: 'Share Post',
                  buttonName: 'Share Now',
                  postModel: postModel,
                  onPressed: (newPostModel) {
                    onUpsert(newPostModel);
                    onAdd(postModel);
                  },
                  userDetails: userDetails,
                  messageResult: messageResult,
                  currentId: sessionService.currentUid
              ),
            );
          },
          icon: Icon(Icons.share),
          tooltip: 'Share',
        ),
      ],
    );
  }
}