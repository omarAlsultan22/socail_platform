import 'current_user_selector.dart';
import 'package:flutter/material.dart';
import '../mixins/more_options_mixin.dart';
import '../../data/models/post_model.dart';
import '../mixins/post_components_mixin.dart';
import 'package:social_app/core/themes/app_theme.dart';
import 'package:social_app/core/utils/time_ago_helper.dart';
import 'package:social_app/core/services/data/session_service.dart';
import 'package:social_app/core/data/models/message_result.dart';
import 'package:social_app/core/helpers/friend_profile_navigator.dart';
import 'package:social_app/features/public/data/models/user_details.dart';
import 'package:social_app/features/public/constants/public_constants.dart';
import 'package:social_app/core/presentation/screens/view_post_screen.dart';
import 'package:social_app/core/presentation/widgets/navigation/navigator.dart';


class PostCard extends StatefulWidget {
  final String? index;
  final String? length;
  final String? userId;
  final PostModel postModel;
  final MessageResult messageResult;
  final SessionService sessionService;
  final void Function(PostModel) onAdd;
  final void Function(PostModel) onUpsert;
  final void Function(PostModel) onRemove;
  final void Function(bool, PostModel) onToggle;

  const PostCard({
    super.key,
    this.index,
    this.length,
    this.userId,
    required this.onAdd,
    required this.onUpsert,
    required this.onRemove,
    required this.onToggle,
    required this.postModel,
    required this.messageResult,
    required this.sessionService
  });

  @override
  _PostCardState createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> with SingleTickerProviderStateMixin, MoreOptionsMixin<PostCard>, PostComponentsMixin<PostCard> {
  late UserDetails _userDetails;

  @override
  String get postType => 'post';

  @override
  String get titleName => 'UpdatePost';

  @override
  String? get userId => widget.userId;

  @override
  PostModel get postModel => widget.postModel;

  @override
  UserDetails get userDetails => _userDetails;

  @override
  void Function(PostModel) get onAdd => widget.onAdd;

  @override
  void Function(PostModel) get onUpsert => widget.onUpsert;

  @override
  void Function(PostModel) get onRemove => widget.onRemove;

  @override
  MessageResult get messageResult => widget.messageResult;

  @override
  SessionService get sessionService => widget.sessionService;

  @override
  void Function(bool, PostModel) get onToggle => widget.onToggle;

  @override
  void initState() {
    super.initState();
    _userDetails = UserDetails();
  }

  void _updateUserDetails(UserDetails userDetails) {
    _userDetails = userDetails;
  }

  @override
  Widget build(BuildContext context) {
    final isPost = !postModel.myDocIdIsEmpty;
    final borderColor = AppTheme.getAdaptiveColor(context);

    return CurrentUserSelector(
        builder: (userDetails) {
          _updateUserDetails(userDetails);
          return Card(
            margin: EdgeInsets.zero,
            child: Stack(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildUserInfo(
                        isRealUser: true, userDetails: userDetails),
                    if (postModel.userId != null &&
                        postModel.userId!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(
                            left: 15.0, right: 15.0),
                        child: Center(
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              border: Border(
                                top: BorderSide(
                                    width: 0.5, color: borderColor),
                                right: BorderSide(
                                    width: 0.5, color: borderColor),
                                left: BorderSide(
                                    width: 0.5, color: borderColor),
                                bottom: isPost
                                    ? BorderSide.none
                                    : BorderSide(
                                    width: 0.5, color: borderColor),
                              ),
                              borderRadius: isPost
                                  ? const BorderRadius.only(
                                  topLeft: Radius.circular(10.0),
                                  topRight: Radius.circular(10.0))
                                  : BorderRadius.circular(10.0),
                            ),
                            child: SizedBox(
                              width: double.infinity,
                              child: _buildUserInfo(isRealUser: false,
                                  userDetails: userDetails),
                            ),
                          ),
                        ),
                      ),
                    _buildPostContent(userDetails),
                  ],
                ),
                Positioned(
                  top: 12.0,
                  right: 0.0,
                  child: buildMoreOptions(),
                )
              ],
            ),
          );
        }
    );
  }

  Widget _buildUserInfo({
    required bool isRealUser,
    required UserDetails userDetails
  }) {
    final sizeFactor = isRealUser ? 1.0 : 0.8;
    final position = isRealUser ? 3.0 : 2.0;
    final avatarSize = 50.0 * sizeFactor;
    final fontSize = 20.0 * sizeFactor;
    final iconSize = 20.0 * sizeFactor;
    final onlineIndicatorSize = 5.0 * sizeFactor;
    final padding = EdgeInsets.only(
      top: 20.0,
      left: isRealUser ? 12.0 : 16.0,
      bottom: 15.0,
      right: 15.0,
    );

    final imageUrl = isRealUser
        ? userDetails.myImageUrl
        : postModel.userImage;
    final name = isRealUser
        ? userDetails.myName
        : postModel.userName;
    final dateTime = isRealUser
        ? postModel.myDateTime
        : postModel.originalDateTime;
    final state = isRealUser
        ? postModel.myState
        : postModel.userState;

    return Padding(
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 15.0),
                child: Stack(
                  alignment: AlignmentDirectional.bottomEnd,
                  children: [
                    ClipOval(
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          splashColor: Colors.blue,
                          onTap: () =>
                              FriendProfileNavigator.handle(
                                  userId: userId,
                                  context: context,
                                  modelUserId: postModel.myId,
                                  sessionService: sessionService
                              ),
                          child: SizedBox(
                            width: avatarSize,
                            height: avatarSize,
                            child: Image.network(
                              imageUrl ?? '',
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) =>
                                  Icon(Icons.person, size: avatarSize),
                            ),
                          ),
                        ),
                      ),
                    ),
                    if (postModel.meIsOnline == true)
                      Padding(
                        padding: EdgeInsetsDirectional.only(
                          bottom: position,
                          end: position,
                        ),
                        child: CircleAvatar(
                          radius: onlineIndicatorSize,
                          backgroundColor: Colors.blue,
                        ),
                      ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  InkWell(
                    onTap: () =>
                        FriendProfileNavigator.handle(
                            userId: userId,
                            context: context,
                            modelUserId: postModel.myId,
                            sessionService: sessionService
                        ),
                    child: Text(
                      name ?? '',
                      style: TextStyle(
                        fontSize: fontSize,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  if (dateTime != null)
                    Row(
                      children: [
                        Text(
                          '${TimeAgoHelper.getTimeAgo(dateTime)} . ',
                          style: TextStyle(fontSize: fontSize * 0.75),
                        ),
                        Icon(
                          PublicConstants.postStatuses[state ?? ''],
                          size: iconSize,
                        ),
                      ],
                    ),
                ],
              ),
            ],
          ),
          if (!postModel.userTextIsEmpty &&
              postModel.userText != null)
            Padding(
              padding: const EdgeInsets.only(top: 8.0, left: 8.0, right: 8.0),
              child: Text(postModel.userText!),
            ),
        ],
      ),
    );
  }

  Widget _buildImageContent(UserDetails userDetails) =>
      Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: NetworkImage(postModel.userPost),
            fit: BoxFit.cover,
          ),
          borderRadius: BorderRadius.circular(8.0),
        ),
        height: 400.0,
        width: double.infinity,
        child: InkWell(
          onTap: () {
            BuildNavigator.build(
              context: context,
              link: ViewPostScreen(
                onAdd: widget.onAdd,
                postModel: postModel,
                userDetails: userDetails,
                onUpsert: widget.onUpsert,
                onRemove: widget.onRemove,
                onToggle: widget.onToggle,
                messageResult: messageResult,
                sessionService: sessionService,
              ),
            );
          },
        ),
      );

  Widget _buildPostContent(UserDetails userDetails) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildContent(_buildImageContent(userDetails)),
        interactionsFeedBack(),
        iconsInteractions()
      ],
    );
  }
}