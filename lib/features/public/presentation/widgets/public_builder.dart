import 'public_status_widget.dart';
import '../cubits/public_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/service _locator.dart';
import 'package:social_app/core/constants/app_sizes.dart';
import 'package:social_app/core/constants/app_colors.dart';
import 'package:social_app/core/constants/app_strings.dart';
import 'package:social_app/core/constants/app_borders.dart';
import 'package:social_app/core/data/models/post_model.dart';
import 'package:social_app/core/constants/app_paddings.dart';
import 'package:social_app/core/constants/app_durations.dart';
import '../../../../core/presentation/widgets/post_card.dart';
import 'package:social_app/core/data/models/message_result.dart';
import 'package:social_app/core/services/data/session_service.dart';
import 'package:social_app/core/presentation/widgets/skeleton_box.dart';
import '../../../../core/presentation/mixins/message_result_mixin.dart';
import '../../../../core/presentation/widgets/current_user_selector.dart';
import 'package:social_app/features/public/data/models/user_details.dart';
import 'package:social_app/core/presentation/widgets/empty_state_widget.dart';
import 'package:social_app/core/presentation/screens/create_post_screen.dart';
import 'package:social_app/core/presentation/widgets/navigation/navigator.dart';
import 'package:social_app/features/public/presentation/states/public_state.dart';
import 'package:social_app/features/public/presentation/widgets/post_template.dart';
import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:social_app/features/public/presentation/widgets/statuses_template.dart';
import 'package:social_app/features/public/presentation/widgets/user_by_userId_selector.dart';


class PublicBuilder extends StatefulWidget {
  final String currentUid;
  final bool hasMorePosts;
  final bool hasMoreStatuses;
  final List<PostModel> homePosts;
  final MessageResult messageResult;
  final void Function(PostModel) onAdd;
  final List<List<PostModel>> homeStatuses;
  final void Function(UserDetails) onUpdate;
  final void Function(PostModel) onUpsertPost;
  final void Function(PostModel) onRemovePost;
  final Future<void> Function() loadMoreStatus;
  final void Function(bool, PostModel) onToggle;
  final void Function(PostModel) onUpsertStatus;
  final void Function(PostModel) onRemoveStatus;

  const PublicBuilder({
    super.key,
    required this.onAdd,
    required this.onUpdate,
    required this.onToggle,
    required this.homePosts,
    required this.currentUid,
    required this.homeStatuses,
    required this.hasMorePosts,
    required this.onUpsertPost,
    required this.onRemovePost,
    required this.messageResult,
    required this.onUpsertStatus,
    required this.onRemoveStatus,
    required this.loadMoreStatus,
    required this.hasMoreStatuses
  });

  @override
  State<PublicBuilder> createState() => _PublicBuilderState();
}

class _PublicBuilderState extends State<PublicBuilder> with WidgetsBindingObserver, MessageResultMixin<PublicBuilder> {
  final ScrollController _scrollControllerStatus = ScrollController();
  bool _isLoadingStatuses = false;
  bool animationToggle = true;

  @override
  void initState() {
    super.initState();
    animationRepeat();
    _scrollControllerStatus.addListener(_onScrollStatus);
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didUpdateWidget(covariant PublicBuilder oldWidget) {
    super.didUpdateWidget(oldWidget);
    handleMessageResult(
        messageResult: widget.messageResult,
        onNavigate: () => Navigator.pop(context));
  }

  void animationRepeat() {
    Future.delayed(AppDurations.debounce, () {
      if (mounted) {
        setState(() {
          animationToggle = !animationToggle;
          animationRepeat();
        });
      }
    });
  }

  @override
  void dispose() {
    _scrollControllerStatus.dispose();
    _scrollControllerStatus.removeListener(_onScrollStatus);
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void _onScrollStatus() {
    if (_scrollControllerStatus.position.pixels >=
        _scrollControllerStatus.position.maxScrollExtent - 200.0 &&
        !_isLoadingStatuses &&
        widget.hasMoreStatuses) {
      _loadMoreStatus();
    }
  }

  Future<void> _loadMoreStatus() async {
    if (_isLoadingStatuses) return;

    setState(() => _isLoadingStatuses = true);
    await widget.loadMoreStatus().whenComplete(() =>
        setState(() => _isLoadingStatuses = false)
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PublicCubit, PublicState>(
        builder: (context, state) {
          return ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery
                  .of(context)
                  .size
                  .height,
            ),
            child: Column(
              children: [
                // Status Section
                SizedBox(
                  height: AppSizes.size200,
                  child: Row(
                    children: [
                      CurrentUserSelector(
                          builder: (userDetails) {
                            widget.onUpdate(userDetails);
                            return Padding(
                              padding: AppPaddings.onlyRight3Left10,
                              child: Container(
                                height: AppSizes.size180,
                                width: AppSizes.size90,
                                decoration: BoxDecoration(
                                  borderRadius: AppBorders.borderRadius_10,
                                  border: Border.all(
                                      color: AppColors.grey, width: 1.0),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.black26,
                                      blurRadius: 4.0,
                                      offset: Offset(2.0, 2.0),
                                    )
                                  ],
                                ),
                                child: InkWell(
                                  onTap: () {
                                    BuildNavigator.build(
                                      context: context,
                                      link: CreatePostScreen(
                                        buttonName: 'Publish',
                                        titleName: 'Create status',
                                        userDetails: userDetails,
                                        messageResult: widget.messageResult,
                                        onPressed: (statusModel) {
                                          widget.onUpsertStatus(statusModel);
                                        },
                                        currentId: widget.currentUid,
                                      ),
                                    );
                                  },
                                  child: Stack(
                                    alignment: AlignmentDirectional.topCenter,
                                    children: [
                                      SizedBox(
                                        height: AppSizes.statusMediaHeight,
                                        width: double.infinity,
                                        child: ClipRRect(
                                          borderRadius: AppBorders.topRounded_10,
                                          child: (!userDetails
                                              .myImageUrlIsEmpty) ?
                                          Image(
                                            image: NetworkImage(
                                                userDetails.myImageUrl),
                                            fit: BoxFit.cover,
                                            errorBuilder: (context, error,
                                                stackTrace) {
                                              return Container(
                                                  color: AppColors.grey);
                                            },
                                          ) : Icon(Icons.person, size: AppSizes.xl),
                                        ),
                                      ),
                                      Positioned(
                                        bottom: 45.0,
                                        child: Container(
                                          height: AppSizes.size30,
                                          width: AppSizes.size30,
                                          decoration: BoxDecoration(
                                            borderRadius: AppBorders
                                                .borderRadius_50,
                                            color: AppColors.primaryBlue,
                                          ),
                                          child: Center(
                                            child: Icon(
                                              Icons.add,
                                              size: AppSizes.size25,
                                              color: AppColors.white,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }
                      ),
                      Expanded(
                        child: ConditionalBuilder(
                          condition: widget.homeStatuses.isNotEmpty,
                          builder: (context) {
                            return ListView.builder(
                              controller: _scrollControllerStatus,
                              scrollDirection: Axis.horizontal,
                              itemCount: widget.homeStatuses.length +
                                  (widget.hasMoreStatuses ? 1 : 0),
                              itemBuilder: (context, index) {
                                if (index < widget.homeStatuses.length) {
                                  final statusModel = widget.homeStatuses[index]
                                      .first;
                                  return UserByUserIdSelector(
                                      postModel: statusModel,
                                      builder: (userDetails) =>
                                          PublicStateWidget(
                                              userDetails: userDetails,
                                              onUpsert: widget.onUpsertStatus,
                                              onRemove: widget.onRemoveStatus,
                                              messageResult: widget
                                                  .messageResult,
                                              statusesList: widget
                                                  .homeStatuses[index]
                                          )
                                  );
                                } else if (_isLoadingStatuses) {
                                  return Padding(
                                    padding: AppPaddings.xs,
                                    child: SkeletonBox(
                                      width: AppSizes.size90,
                                      height: AppSizes.size180,
                                      animationToggle: animationToggle,
                                      borderRadius: AppBorders.borderRadius_10,
                                    ),
                                  );
                                } else {
                                  return EmptyStateWidget();
                                }
                              },
                            );
                          },
                          fallback: (context) =>
                              StatusesTemplate(
                                  animationToggle: animationToggle),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(height: 1.0, color: AppColors.grey),
                // Posts Section
                ConditionalBuilder(
                  condition: widget.homePosts.isNotEmpty,
                  builder: (context) {
                    return ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: widget.homePosts.length +
                          (widget.hasMorePosts ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index < widget.homePosts.length) {
                          final postModel = widget.homePosts[index];
                          return UserByUserIdSelector(
                              postModel: postModel,
                              builder: (userDetails) =>
                                  PostCard(
                                    onAdd: widget.onAdd,
                                    onToggle: widget.onToggle,
                                    onUpsert: widget.onUpsertPost,
                                    onRemove: widget.onRemovePost,
                                    postModel: widget.homePosts[index],
                                    messageResult: widget.messageResult,
                                    sessionService: sl<SessionService>(),
                                  )
                          );
                        }
                        else {
                          return widget.hasMorePosts ? Padding(
                            padding: AppPaddings.medium,
                            child: Center(child: Text(
                              AppStrings.loadingMore,
                              style: TextStyle(
                                  color: AppColors.primaryBlue
                              ),
                            )),
                          ) :
                          const EmptyStateWidget();
                        }
                      },
                    );
                  },
                  fallback: (context) =>
                      PostTemplate(animationToggle: animationToggle),
                ),
              ],
            ),
          );
        }
    );
  }
}