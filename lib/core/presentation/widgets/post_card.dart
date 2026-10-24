import 'current_user_selector.dart';
import 'package:flutter/material.dart';
import '../mixins/more_options_mixin.dart';
import '../../data/models/post_model.dart';
import '../mixins/post_components_mixin.dart';
import 'package:social_app/core/themes/app_theme.dart';
import 'package:social_app/core/constants/app_sizes.dart';
import 'package:social_app/core/constants/app_colors.dart';
import 'package:social_app/core/constants/app_strings.dart';
import 'package:social_app/core/utils/time_ago_helper.dart';
import 'package:social_app/core/constants/app_borders.dart';
import 'package:social_app/core/constants/app_paddings.dart';
import 'package:social_app/core/data/models/message_result.dart';
import 'package:social_app/core/services/data/session_service.dart';
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
  // ===== ثابت خاص بالملف =====
  static const double _borderWidth = 0.5;

  late UserDetails _userDetails;

  @override
  String get postType => AppStrings.post;

  @override
  String get titleName => AppStrings.updatePost;

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

  BorderSide _borderSide(Color color) =>
      BorderSide(width: _borderWidth, color: color);

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
                        padding: AppPaddings.onlyLeft15Right15,
                        child: Center(
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              border: Border(
                                top: _borderSide(borderColor),
                                right: _borderSide(borderColor),
                                left: _borderSide(borderColor),
                                bottom: isPost
                                    ? BorderSide.none
                                    : _borderSide(borderColor),
                              ),
                              borderRadius: isPost
                                  ? AppBorders.topRounded_10
                                  : AppBorders.borderRadius_10,
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
    final avatarSize = AppSizes.xl * sizeFactor;
    final fontSize = 20.0 * sizeFactor;
    final iconSize = 20.0 * sizeFactor;
    final onlineIndicatorSize = AppSizes.onlineIndicator * sizeFactor;
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
                padding: AppPaddings.onlyRight15,
                child: Stack(
                  alignment: AlignmentDirectional.bottomEnd,
                  children: [
                    ClipOval(
                      child: Material(
                        color: AppColors.transparent,
                        child: InkWell(
                          splashColor: AppColors.primaryBlue,
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
                              imageUrl ?? AppStrings.empty,
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
                          backgroundColor: AppColors.primaryBlue,
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
                      name ?? AppStrings.empty,
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
                          PublicConstants.postStatuses[state ??
                              AppStrings.empty],
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
              padding: AppPaddings.textContent,
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
          borderRadius: AppBorders.borderRadius_8,
        ),
        height: AppSizes.size400,
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