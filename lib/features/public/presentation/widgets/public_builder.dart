import '../cubits/public_cubit.dart';
import 'package:flutter/material.dart';
import 'public_status_widget.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_app/core/data/models/post_model.dart';
import 'package:social_app/core/services/session_service.dart';
import '../../../../core/presentation/widgets/new/post_card.dart';
import 'package:social_app/core/presentation/screens/create_post_screen.dart';
import 'package:social_app/core/presentation/widgets/navigation/navigator.dart';
import 'package:social_app/features/public/presentation/states/public_state.dart';
import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';


class PublicBuilder extends StatefulWidget {
  final String? userImage;
  final bool hasMorePosts;
  final bool hasMoreStatuses;
  final List<PostModel> homePosts;
  final SessionService sessionService;
  final List<List<PostModel>> homeStatuses;
  final Future<void> Function() loadMoreStatus;
  final void Function(PostModel) insertAndUpdateStatuses;

  const PublicBuilder({
    super.key,
    this.userImage,
    required this.homePosts,
    required this.homeStatuses,
    required this.hasMorePosts,
    required this.sessionService,
    required this.loadMoreStatus,
    required this.hasMoreStatuses,
    required this.insertAndUpdateStatuses
  });

  @override
  State<PublicBuilder> createState() => _PublicBuilderState();
}

class _PublicBuilderState extends State<PublicBuilder> with WidgetsBindingObserver {
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

  void animationRepeat() {
    Future.delayed(Duration(milliseconds: 500), () {
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
                  height: 200,
                  child: Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right: 3.0, left: 10.0),
                        child: Container(
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
                          child: InkWell(
                            onTap: () {
                              BuildNavigator.build(
                                context: context,
                                link: CreatePostScreen(
                                  buttonName: 'Publish',
                                  titleName: 'Create status',
                                  onPressed: (statusModel) {
                                    widget.insertAndUpdateStatuses(statusModel);
                                  }, uId: widget.sessionService,
                                ),
                              );
                            },
                            child: Stack(
                              alignment: AlignmentDirectional.topCenter,
                              children: [
                                SizedBox(
                                  height: 120.0,
                                  width: double.infinity,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(10.0),
                                      topRight: Radius.circular(10.0),
                                    ),
                                    child: (widget.userImage != null &&
                                        widget.userImage!.isNotEmpty) ?
                                    Image(
                                      image: NetworkImage(
                                          widget.userImage!),
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error,
                                          stackTrace) {
                                        return Container(color: Colors.grey);
                                      },
                                    ) : Icon(Icons.person, size: 50.0),
                                  ),
                                ),
                                Positioned(
                                  bottom: 45.0,
                                  child: Container(
                                    height: 30.0,
                                    width: 30.0,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(50.0),
                                      color: Colors.blue.shade900,
                                    ),
                                    child: Center(
                                      child: Icon(
                                        Icons.add,
                                        size: 25.0,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
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
                                  return PublicStateWidget(
                                    statusesList: widget.homeStatuses[index],
                                  );
                                } else if (_isLoadingStatuses) {
                                  return Padding(padding: EdgeInsets.all(8.0),
                                    child: Container(
                                      height: 180.0,
                                      width: 90.0,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(
                                            10.0),
                                        border: Border.all(
                                            color: Colors.grey.shade400,
                                            width: 1.0),
                                        boxShadow: [
                                          BoxShadow(
                                              color: Colors.black26,
                                              blurRadius: 4.0,
                                              offset: Offset(2.0, 2.0))
                                        ],
                                      ),
                                    ),
                                  );
                                } else {
                                  return SizedBox();
                                }
                              },
                            );
                          },
                          fallback: (context) => _statusesTemplate(),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(height: 1.0, color: Colors.grey),

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
                          return PostCard(
                            sessionService: widget.sessionService,
                            postModel: widget.homePosts[index],
                          );
                        }
                        else {
                          return widget.hasMorePosts ? Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Center(child: Text(
                              'Loading more...',
                              style: TextStyle(
                                  color: Colors.blue.shade700
                              ),
                            )),
                          ) :
                          const SizedBox();
                        }
                      },
                    );
                  },
                  fallback: (context) => _postsTemplate(),
                ),
              ],
            ),
          );
        });
  }

  Widget _postsTemplate() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(
            top: 20.0,
            left: 12.0,
            bottom: 15.0,
            right: 15.0,
          ),
          child: ClipOval(
            child: Material(
              child: InkWell(
                child: AnimatedContainer(
                  duration: Duration(seconds: 1),
                  curve: Curves.easeInOut,
                  decoration: BoxDecoration(
                      color: Theme
                          .of(context)
                          .brightness == Brightness.light ?
                      animationToggle ? Colors.transparent : Colors.black12 :
                      animationToggle ? Colors.transparent : Colors.black87,
                      borderRadius: BorderRadius.circular(50.0),
                      border: Border.all(
                          color: Colors.grey.shade400,
                          width: 1.0),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black26,
                            blurRadius: 4.0

                        )
                      ]),
                  width: 50.0,
                  height: 50.0,
                ),
              ),
            ),
          ),
        ),
        AnimatedContainer(
          duration: Duration(seconds: 1),
          width: double.infinity,
          height: 400.0,
          curve: Curves.easeInOut,
          decoration: BoxDecoration(
              color: Theme
                  .of(context)
                  .brightness == Brightness.light ?
              animationToggle ? Colors.transparent : Colors.black12 :
              animationToggle ? Colors.transparent : Colors.black87,
              borderRadius: BorderRadius.circular(8.0),
              border: Border.all(
                  color: Colors.grey.shade400,
                  width: 1.0),
              boxShadow: [
                BoxShadow(
                    color: Colors.black26,
                    blurRadius: 4.0
                )
              ]),
        ),
      ],
    );
  }

  Widget _statusesTemplate() {
    return ListView(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        scrollDirection: Axis.horizontal,
        children: List.generate(10, (index) {
          return Padding(
            padding: const EdgeInsets.symmetric(
                vertical: 10.0, horizontal: 3.0),
            child: Stack(
              children: [
                AnimatedContainer(
                  duration: Duration(seconds: 1),
                  height: 180.0,
                  width: 90.0,
                  curve: Curves.easeInOut,
                  decoration: BoxDecoration(
                    color: Theme
                        .of(context)
                        .brightness == Brightness.light ?
                    animationToggle ? Colors.transparent : Colors.black12 :
                    animationToggle ? Colors.transparent : Colors.black87,
                    borderRadius: BorderRadius.circular(10.0),
                    border: Border.all(color: Colors.grey, width: 1.0),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black26,
                          blurRadius: 4.0,
                          offset: Offset(2.0, 2.0))
                    ],
                  ),
                ),
                Positioned(
                  top: 8.0,
                  left: 8.0,
                  child: AnimatedContainer(
                    duration: Duration(seconds: 1),
                    height: 25.0,
                    width: 25.0,
                    curve: Curves.easeInOut,
                    decoration: BoxDecoration(
                      color: Theme
                          .of(context)
                          .brightness == Brightness.light ?
                      animationToggle ? Colors.transparent : Colors.black12 :
                      animationToggle ? Colors.transparent : Colors.black87,
                      borderRadius: BorderRadius.circular(50.0),
                      border: Border.all(color: Colors.grey, width: 1.0),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black26,
                            blurRadius: 4.0,
                            offset: Offset(2.0, 2.0))
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        })
    );
  }
}