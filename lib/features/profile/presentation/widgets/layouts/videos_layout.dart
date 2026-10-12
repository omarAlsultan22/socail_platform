import 'package:flutter/material.dart';
import 'package:social_app/core/data/models/post_model.dart';
import 'package:social_app/core/data/models/message_result.dart';
import '../../../../../core/presentation/widgets/current_user_selector.dart';
import 'package:social_app/core/presentation/widgets/new/video_content_widget.dart';


class VideosLayout extends StatefulWidget {
  final bool hasMoreVideos;
  final VoidCallback onScroll;
  final List<PostModel> videosList;
  final MessageResult messageResult;
  final void Function(PostModel) onAdd;
  final void Function(PostModel) onUpsert;
  final void Function(PostModel) onRemove;
  final void Function(bool, PostModel) onToggle;
  const VideosLayout({
    super.key,
    required this.onAdd,
    required this.onUpsert,
    required this.onRemove,
    required this.onToggle,
    required this.onScroll,
    required this.videosList,
    required this.hasMoreVideos,
    required this.messageResult
  });

  @override
  State<VideosLayout> createState() => _VideosLayoutState();
}

class _VideosLayoutState extends State<VideosLayout> {
  bool _isLoadingPosts = false;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScrollPosts);
  }

  void _onScrollPosts() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200.0 &&
        widget.hasMoreVideos) {
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
        padding: const EdgeInsets.all(8.0),
        child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(padding: EdgeInsets.only(top: 20.0),
                child: Text("My Videos",
                  style: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold
                  ),
                ),
              ),
              Padding(
                  padding: const EdgeInsets.only(top: 20.0),
                  child: GridView.count(
                    controller: _scrollController,
                    crossAxisCount: 3,
                    shrinkWrap: true,
                    crossAxisSpacing: 5.0,
                    mainAxisSpacing: 5.0,
                    physics: const NeverScrollableScrollPhysics(),
                    children: widget.videosList.map((e) {
                      return CurrentUserSelector(
                          builder: (userDetails) =>
                              VideoContentWidget(
                                  postModel: e,
                                  height: 200.0,
                                  width: 200.0,
                                  onAdd: widget.onAdd,
                                  userDetails: userDetails,
                                  onUpsert: widget.onUpsert,
                                  onRemove: widget.onRemove,
                                  onToggle: widget.onToggle,
                                  messageResult: widget.messageResult
                              )
                      );
                    }).toList(),
                  )
              ),
            ]
        )
    );
  }
}




