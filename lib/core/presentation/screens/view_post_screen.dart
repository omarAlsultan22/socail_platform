import 'package:flutter/material.dart';
import '../../data/models/post_model.dart';
import 'package:social_app/core/constants/app_colors.dart';
import 'package:social_app/core/constants/app_strings.dart';
import 'package:social_app/core/utils/time_ago_helper.dart';
import 'package:social_app/core/constants/app_paddings.dart';
import 'package:social_app/core/constants/app_text_styles.dart';
import '../../../features/public/data/models/user_details.dart';
import 'package:social_app/core/data/models/message_result.dart';
import 'package:social_app/core/services/data/session_service.dart';
import 'package:social_app/features/public/constants/public_constants.dart';
import 'package:social_app/core/presentation/mixins/more_options_mixin.dart';
import 'package:social_app/core/presentation/mixins/post_components_mixin.dart';


class ViewPostScreen extends StatefulWidget {
  final String? userId;
  final PostModel postModel;
  final UserDetails userDetails;
  final MessageResult messageResult;
  final SessionService sessionService;
  final void Function(PostModel) onAdd;
  final void Function(PostModel) onUpsert;
  final void Function(PostModel)? onRemove;
  final void Function(bool, PostModel) onToggle;

  const ViewPostScreen({
    super.key,
    this.userId,
    this.onRemove,
    required this.onAdd,
    required this.onUpsert,
    required this.onToggle,
    required this.postModel,
    required this.userDetails,
    required this.messageResult,
    required this.sessionService,
  });

  @override
  State<ViewPostScreen> createState() => _ViewPostScreenState();
}

class _ViewPostScreenState extends State<ViewPostScreen> with SingleTickerProviderStateMixin, MoreOptionsMixin<ViewPostScreen>, PostComponentsMixin<ViewPostScreen> {

  @override
  String get postType => AppStrings.post;

  @override
  String get titleName => AppStrings.updatePost;

  @override
  String? get userId => widget.userId;

  @override
  PostModel get postModel => widget.postModel;

  @override
  UserDetails get userDetails => widget.userDetails;

  @override
  MessageResult get messageResult => widget.messageResult;

  @override
  SessionService get sessionService => widget.sessionService;

  @override
  void Function(PostModel) get onAdd => widget.onAdd;

  @override
  void Function(PostModel) get onUpsert => widget.onUpsert;

  @override
  void Function(PostModel)? get onRemove => widget.onRemove;

  @override
  void Function(bool, PostModel) get onToggle => widget.onToggle;

  @override
  Widget build(BuildContext context) {
    final post = postModel;
    final userText = post.userText;
    final userState = post.userState;
    final dateTime = post.myDateTime;

    return Scaffold(
      body: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: AppPaddings.onlyTop15,
                child: IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(Icons.close, size: 25.0),
                ),
              ),
              userId == sessionService.currentUid ?
              buildMoreOptions() : SizedBox()
            ],
          ),
          SizedBox(height: 50.0),
          buildContent(_buildImageContent()),
          Padding(
            padding: AppPaddings.textContent,
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            userDetails.myName,
                            style: AppTextStyles.boldBody,
                          ),
                          Row(
                            children: [
                              Text(
                                '${TimeAgoHelper.getTimeAgo(
                                    dateTime!)} . ',
                                style: AppTextStyles.bodySmall,
                              ),
                              Icon(PublicConstants.postStatuses[userState],
                                  size: 15.0),
                            ],
                          ),
                          if (userText != null)
                            Text(userText),
                          interactionsFeedBack()
                        ],
                      ),
                    ),
                  ],
                ),
                Container(height: 1.0, color: AppColors.grey),
                iconsInteractions()
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageContent() {
    final userPost = postModel.userPost;
    return Expanded(
      child: SizedBox(
        height: 200.0,
        width: double.infinity,
        child: !postModel.userPostIsEmpty
            ? Image(
          image: NetworkImage(userPost),
          fit: BoxFit.cover,
        )
            : Icon(Icons.person, size: 100.0),
      ),
    );
  }
}