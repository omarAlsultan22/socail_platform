import '../view_images.dart';
import 'package:flutter/material.dart';
import '../../../constants/profile_strings.dart';
import '../../../data/models/albums_buttons.dart';
import '../../../../../core/data/models/message_result.dart';
import 'package:social_app/core/data/models/post_model.dart';
import '../../../../../core/data/models/paginated_posts.dart';
import 'package:social_app/features/profile/constants/photo_section.dart';


class PhotosLayout extends StatefulWidget {
  final int currentIndex;
  final MessageResult messageResult;
  final void Function(int) changeIndex;
  final void Function(PostModel) onAdd;
  final void Function(PostModel) onUpsert;
  final void Function(PostModel) onRemove;
  final void Function(bool, PostModel) onToggle;
  final Map<int, PaginatedPosts> paginatedPostsMap;
  final Map<int, Future<void> Function()> listenerScreens;

  const PhotosLayout({
    super.key,
    required this.onAdd,
    required this.onUpsert,
    required this.onRemove,
    required this.onToggle,
    required this.changeIndex,
    required this.currentIndex,
    required this.messageResult,
    required this.listenerScreens,
    required this.paginatedPostsMap
  });

  @override
  State<PhotosLayout> createState() => _PhotosLayoutState();
}

class _PhotosLayoutState extends State<PhotosLayout> {
  bool _isLoadingPosts = false;
  final ScrollController _scrollController = ScrollController();

  // ✅ Getters
  PaginatedPosts get _current => widget.paginatedPostsMap[widget.currentIndex]!;
  bool get hasMoreData => _current.hasMoreData;
  List<PostModel> get postsImages => widget.paginatedPostsMap[PhotoSection.posts]!.dataList;
  List<PostModel> get coverPhotos => widget.paginatedPostsMap[PhotoSection.cover]!.dataList;
  List<PostModel> get profilePictures => widget.paginatedPostsMap[PhotoSection.profile]!.dataList;

  List<ViewImages> get _albumsScreens => [
    ViewImages(
      onAdd: widget.onAdd,
      onUpsert: widget.onUpsert,
      onRemove: widget.onRemove,
      onToggle: widget.onToggle,
      imagesList: postsImages,
      messageResult: widget.messageResult,
      title: ProfileStrings.postsImages,
    ),
    ViewImages(
      onAdd: widget.onAdd,
      onUpsert: widget.onUpsert,
      onRemove: widget.onRemove,
      onToggle: widget.onToggle,
      imagesList: profilePictures,
      messageResult: widget.messageResult,
      title: ProfileStrings.profilePictures,
    ),
    ViewImages(
      onAdd: widget.onAdd,
      onUpsert: widget.onUpsert,
      onRemove: widget.onRemove,
      onToggle: widget.onToggle,
      imagesList: coverPhotos,
      messageResult: widget.messageResult,
      title: ProfileStrings.coverPhotos,
    ),
  ];

  List<AlbumsButtons> get _albumsButtons => [
    AlbumsButtons(
        id: 0, albumImages: postsImages, albumText: ProfileStrings.postsImages),
    AlbumsButtons(
        id: 1, albumImages: profilePictures, albumText: ProfileStrings.profilePictures),
    AlbumsButtons(
        id: 2, albumImages: coverPhotos, albumText: ProfileStrings.coverPhotos),
  ];

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScrollPosts);
  }

  void _onScrollPosts() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200.0 &&
        hasMoreData) {
      _loadMorePosts();
    }
  }

  Future<void> _loadMorePosts() async {
    if (_isLoadingPosts) return;

    setState(() => _isLoadingPosts = true);
    widget.listenerScreens[widget.currentIndex]!.call();
    setState(() => _isLoadingPosts = false);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min, // Important change
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 10.0),
                  child: Text(
                    "Albums",
                    style: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 20.0),
                  child: SizedBox(
                    height: 220.0,
                    child: AlbumsList(
                      albumsButtons: _albumsButtons,
                      onPressed: (index) {
                        widget.changeIndex(index);
                      },
                      currentIndex: widget.currentIndex,
                    ),
                  ),
                ),
                Container(height: 1.0, color: Colors.grey),
                _albumsScreens[widget.currentIndex],
              ],
            ),
          ),
    );
  }
}


class AlbumsList extends StatelessWidget {
  final List<AlbumsButtons> albumsButtons;
  final Function(int) onPressed;
  final int currentIndex;

  const AlbumsList({
    required this.albumsButtons,
    required this.onPressed,
    required this.currentIndex,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final filteredAlbums = albumsButtons
        .asMap()
        .entries
        .where((entry) => entry.key != currentIndex)
        .toList();

    return Row(
      children: filteredAlbums.map((entry) {
        final index = entry.key;
        final album = entry.value;
        return Expanded(
          child: AlbumLayout(
            albumIButtons: album,
            onPressed: () => onPressed(index),
          ),
        );
      }).toList(),
    );
  }
}


class AlbumLayout extends StatelessWidget {
  final VoidCallback onPressed;
  final AlbumsButtons albumIButtons;

  const AlbumLayout({
    super.key,
    required this.onPressed,
    required this.albumIButtons
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AspectRatio(
            aspectRatio: 1,
            child: Container(
              height: 180.0,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.0),
                border: Border.all(color: Colors.white70),
              ),
              child: InkWell(
                onTap: onPressed,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10.0),
                  child: albumIButtons.imagesListIsNotEmpty
                      ? Image.network(
                    albumIButtons.userPost ?? '',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey,
                        child: const Icon(Icons.image),
                      );
                    },
                  )
                      : SizedBox(),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8.0),
          Text(
            albumIButtons.albumText,
            style: const TextStyle(
              fontSize: 16.0,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}