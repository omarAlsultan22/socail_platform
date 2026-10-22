import 'package:flutter/material.dart';
import '../../../../../core/data/models/post_model.dart';
import 'package:social_app/core/data/models/my_model.dart';
import 'package:social_app/core/services/data/session_service.dart';
import 'package:social_app/core/data/models/profile_info.dart';
import 'package:social_app/core/data/models/message_result.dart';
import '../../../../../core/presentation/widgets/list_builder.dart';
import 'package:social_app/core/presentation/widgets/post_card.dart';
import '../../../../../core/presentation/widgets/current_user_selector.dart';
import '../../../../../core/presentation/widgets/layouts/user_row_layout.dart';
import 'package:social_app/core/presentation/widgets/navigation/navigator.dart';
import 'package:social_app/core/presentation/widgets/create_post_input_widget.dart';
import 'package:social_app/features/profile/presentation/screens/user_profile_screen.dart';


class PostsLayout extends StatefulWidget {
  final String userId;
  final bool hasMorePosts;
  final VoidCallback onScroll;
  final ProfileInfo profileInfo;
  final List<PostModel> postsList;
  final List<MyModel> friendsList;
  final MessageResult messageResult;
  final SessionService sessionService;
  final void Function(PostModel) onAdd;
  final void Function(PostModel) onUpsert;
  final void Function(PostModel) onRemove;
  final void Function(bool, PostModel) onToggle;

  const PostsLayout({
    super.key,
    required this.onAdd,
    required this.userId,
    required this.onUpsert,
    required this.onRemove,
    required this.onToggle,
    required this.onScroll,
    required this.postsList,
    required this.profileInfo,
    required this.friendsList,
    required this.hasMorePosts,
    required this.messageResult,
    required this.sessionService,
  });

  @override
  State<PostsLayout> createState() => _PostsLayoutState();
}

class _PostsLayoutState extends State<PostsLayout> {
  late int length;
  bool _isLoadingPosts = false;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    length = widget.friendsList.length;
    _scrollController.addListener(_onScrollPosts);
  }

  void _onScrollPosts() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200.0 &&
        widget.hasMorePosts) {
      _loadMorePosts();
    }
  }

  Future<void> _loadMorePosts() async {
    if (_isLoadingPosts) return;

    setState(() => _isLoadingPosts = true);
    widget.onScroll();
    setState(() => _isLoadingPosts = false);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Details',
              style: TextStyle(
                  fontSize: 18.0, fontWeight: FontWeight.bold),
            ),
            _personalDetails(icon: Icons.work,
                textAddress: 'Works at',
                textValue: widget.profileInfo.userWork),
            _personalDetails(icon: Icons.home_filled,
                textAddress: 'Lives in',
                textValue: widget.profileInfo.userLive),
            _personalDetails(icon: Icons.location_on_sharp,
                textAddress: 'From',
                textValue: widget.profileInfo.userFrom),
            _personalDetails(icon: Icons.favorite,
                textAddress: widget.profileInfo.userRelational),
            Container(height: 1.0, color: Colors.grey),
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: GestureDetector(
                onTap: () =>
                    BuildNavigator.build(context: context,
                        link: _friendsScreen()
                    ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text('Friends', style: TextStyle(
                        fontSize: 18.0, fontWeight: FontWeight.bold)),
                    Text('friends ${widget.friendsList.length}',
                        style: TextStyle(fontSize: 16.0)),
                  ],
                ),
              ),
            ),
            _showFriends(friends: widget.friendsList,
                count: 3,
                startIndex: 0,
                length: length
            ),
            _showFriends(friends: widget.friendsList,
                count: 3,
                startIndex: 3,
                length: length
            ),
            Container(height: 1.0, color: Colors.grey),
            widget.userId == widget.sessionService.currentUid ?
            PostCreationWidget(
              uId: widget.userId,
              onUpsert: widget.onUpsert,
              messageResult: widget.messageResult,
            ) : SizedBox(),
            Container(height: 1.0, color: Colors.grey),
            _postsBuilder(
              profileData: widget.postsList,
            )
          ],
        )
    );
  }

  Widget _friendsScreen() =>
      Scaffold(
        appBar: AppBar(
          scrolledUnderElevation: 0.0,
        ),
        body: ListBuilder(
            list: widget.friendsList,
            object: (friend) =>
                UserRowLayout(userRow: friend, userId: widget.userId),
            fallback: Text('There no any friends yet')
        ),
      );

  Widget _postsBuilder({
    required List<PostModel> profileData,
  }) =>
      SizedBox(
        child: ListView.separated(
          shrinkWrap: true,
          controller: _scrollController,
          physics: const NeverScrollableScrollPhysics(),
          itemBuilder: (context, index) {
            if (index < widget.postsList.length) {
              final postModel = profileData[index];

              return CurrentUserSelector(
                  builder: (userDetails) =>
                      PostCard(
                        onAdd: widget.onAdd,
                        userId: widget.userId,
                        index: index.toString(),
                        onUpsert: widget.onUpsert,
                        onRemove: widget.onRemove,
                        onToggle: widget.onToggle,
                        postModel: postModel,
                        messageResult: widget.messageResult,
                        sessionService: widget.sessionService,
                        length: (profileData.length + 1).toString(),
                      )
              );
            } else {
              return widget.hasMorePosts
                  ? Padding(
                padding: const EdgeInsets.all(16.0),
                child: Center(
                  child: Text(
                    'Loading more...',
                    style: TextStyle(color: Colors.blue.shade700),
                  ),
                ),
              )
                  : const SizedBox();
            }
          },
          separatorBuilder: (context, index) =>
          const SizedBox(height: 1.0),
          itemCount: profileData.length,
        ),
      );

  Padding _personalDetails({
    String? textValue,
    String? textAddress,
    required IconData icon,
  }) =>
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 10.0),
        child: Row(
            children: [
              Icon(icon),
              Text(textAddress ?? 'N/A',
                style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.normal
                ),
              ),
              Text(textValue ?? 'N/A',
                style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold
                ),
              )
            ]
        ),
      );

  Widget _friendImage({
    required String image,
    required String text,
    required VoidCallback onTap,
  }) =>
      Expanded(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              AspectRatio(
                aspectRatio: 1,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  height: 100.0,
                  child: InkWell(
                    onTap: onTap,
                    child: Image(image: NetworkImage(image), fit: BoxFit.cover),
                  ),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: InkWell(
                  onTap: onTap,
                  child: Text(text,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(),),
                ),
              )
            ],
          ),
        ),
      );

  Row _showFriends({
    required int length,
    required int count,
    required int startIndex,
    required List<MyModel> friends
  }) {
    if (startIndex >= length) return Row();

    int remaining = length - startIndex;
    int displayCount = remaining < count ? remaining : count;

    return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(displayCount, (index) {
          int friendIndex = startIndex + index;
          if (friendIndex >= length) return SizedBox();

          final friendModel = friends[friendIndex];
          final userId = friendModel.myId;

          return _friendImage(
              text: friendModel.myName,
              image: friendModel.myImageUrl,
              onTap: () {
                if (userId.isNotEmpty) {
                  BuildNavigator.build(
                      context: context,
                      link: UserProfileScreen(
                          friendId: userId
                      )
                  );
                }
              });
        })
    );
  }
}