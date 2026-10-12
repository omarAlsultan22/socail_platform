import 'package:flutter/material.dart';
import '../../../data/models/post_model.dart';
import 'package:social_app/core/utils/time_ago_helper.dart';
import 'package:social_app/core/services/session_service.dart';
import 'package:social_app/core/data/models/message_result.dart';
import '../../../../features/public/data/models/user_details.dart';
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
  String get postType => 'post';

  @override
  String get titleName => 'UpdatePost';

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
                padding: const EdgeInsets.only(top: 15.0),
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
                            userDetails.myName,
                            style: const TextStyle(
                              fontSize: 15.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Row(
                            children: [
                              Text(
                                '${TimeAgoHelper.getTimeAgo(
                                    dateTime!)} . ',
                                style: TextStyle(fontSize: 13.0),
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
                Container(height: 1.0, color: Colors.grey),
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
        child: postModel.userPost != null
            ? Image(
          image: NetworkImage(userPost ?? ''),
          fit: BoxFit.cover,
        )
            : Icon(Icons.person, size: 100.0),
      ),
    );
  }
}