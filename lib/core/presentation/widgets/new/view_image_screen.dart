import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../../../data/models/post_model.dart';
import 'package:social_app/features/profile/cubit.dart';
import '../../../../features/interactions/likes_list/cubit.dart';
import '../../../../features/interactions/likes_list/likes_list.dart';
import 'package:social_app/features/public/utils/time_ago_helper.dart';
import 'package:social_app/features/public/constants/public_constants.dart';
import '../../../../features/interactions/comments_list/comments_list.dart';
import 'package:social_app/core/presentation/widgets/navigation/navigator.dart';
import 'package:social_app/core/presentation/widgets/new/icon_button_widget.dart';
import 'package:social_app/features/public/presentation/screens/create_post_screen.dart';


class ViewImageScreen extends StatefulWidget {
  final PostModel postModel;
  const ViewImageScreen({
    required this.postModel,
    super.key
  });

  @override
  State<ViewImageScreen> createState() => _ViewImageScreenState();
}

class _ViewImageScreenState extends State<ViewImageScreen> {
  late bool isActive;
  late int likes;
  late int comments;
  late int shares;

  void likeToggle(){
    setState(() {
      isActive = !isActive;
      likes += isActive ? 1 : -1;
    });
    chickLike(
        isActive: isActive,
        postModel: widget.postModel
    );
  }

  Future<void> chickLike({
    required bool isActive,
    required PostModel postModel,
  }) async {
    if (isActive) {
      await LikesCubit.get(context).addLike(
          postId: postModel.docId!, userId: postModel.userId!);

    }
    else {
      LikesCubit.get(context).deleteLike(
          postId: postModel.docId!, userId: postModel.userId!);
    }
  }

  @override
  void initState() {
    super.initState();
    likes = widget.postModel.likesNumber ?? 0;
    comments = widget.postModel.commentsNumber ?? 0;
    shares = widget.postModel.sharesNumber ?? 0;
    isActive = widget.postModel.isActive;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 15.0),
                child: IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(Icons.close, size: 25.0),
                ),
              ),
            ],
          ),
          SizedBox(height: 50.0),
          Expanded(
            child: Container(
              height: 200.0,
              width: double.infinity,
              child: widget.postModel.userPost != null
                  ? Image(
                image: NetworkImage(widget.postModel.userPost ?? ''),
                fit: BoxFit.cover,
              )
                  : Icon(Icons.person, size: 100.0),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(
                right: 10.0, left: 10.0, top: 10.0),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.postModel.userName!,
                            style: const TextStyle(
                              fontSize: 15.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Row(
                            children: [
                              Text(
                                '${TimeAgoHelper.getTimeAgo(widget.postModel.dateTime!)} . ',
                                style: TextStyle(fontSize: 13.0),
                              ),
                              Icon(PublicConstants.postStatuses[widget.postModel.userState], size: 15.0),
                            ],
                          ),
                          if (widget.postModel.friendText != null)
                            Text(widget.postModel.friendText ?? ''),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10.0),
                            child: InkWell(
                              onTap: () {
                                BuildNavigator.build(
                                  context: context,
                                  link: LikesScreen(docId: widget.postModel.docId ?? ''),
                                );
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10.0),
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
                                                  link: LikesScreen(docId: widget.postModel.docId!),
                                                ),
                                            child: Container(
                                              decoration: BoxDecoration(
                                                color: Colors.red,
                                                borderRadius: BorderRadius.circular(50.0),
                                              ),
                                              child: Padding(
                                                padding: const EdgeInsets.all(3.0),
                                                child: Icon(
                                                  Icons.favorite,
                                                  size: 15,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                          ),
                                          SizedBox(width: 5.0),
                                          Text(likes.toString()),
                                        ],
                                      ),

                                    Row(
                                      children: [
                                        if (comments > 0)
                                          GestureDetector(
                                            onTap: () => BuildNavigator.build(
                                              context: context,
                                              link: CommentsScreen(docId: widget.postModel.docId!, userId: widget.postModel.userId,),
                                            ),
                                            child: Padding(
                                              padding: EdgeInsets.only(right: 15),
                                              child: Text('${comments.toString()} comments'),
                                            ),
                                          ),
                                        if (shares > 0)
                                          GestureDetector(
                                            onTap: () => BuildNavigator.build(
                                              context: context,
                                              link: CommentsScreen(docId: widget.postModel.docId!, userId: widget.postModel.userId),
                                            ),
                                            child: Text('${shares.toString()} shares'),
                                          ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Container(height: 1.0, color: Colors.grey),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    IconButtonWidget(
                      onPressed: likeToggle,
                      icon: Icon(isActive ? Icons.favorite : Icons.favorite_border),
                      tooltip: 'Like',
                    ),
                    IconButtonWidget(
                      onPressed: () {
                        BuildNavigator.build(
                          context: context,
                          link:  CommentsScreen(docId: widget.postModel.docId!, userId: widget.postModel.userId),
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
                            postModel: widget.postModel,
                            onPressed: (postModel) {
                              BuildNavigator.build(
                                context: context,
                                link: CreatePostScreen(
                                  titleName: 'Share Post',
                                  buttonName: 'Share Now',
                                  postModel: widget.postModel,
                                  onPressed: (newPostModel) {
                                    HomeCubit
                                        .get(context).insertAndUpdatePosts(postModel: newPostModel);
                                    ProfileCubit
                                        .get(context)
                                        .insertAndUpdatePosts(postModel: newPostModel);
                                  },
                                ),
                              );
                            },
                          ),
                        );
                      },
                      icon: Icon(Icons.share),
                      tooltip: 'share',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}