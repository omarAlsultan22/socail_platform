import '../view_images.dart';
import 'package:flutter/material.dart';
import '../../../constants/profile_strings.dart';
import '../../../data/models/albums_buttons.dart';
import '../../../../../core/constants/app_spaces.dart';
import 'package:social_app/core/constants/app_sizes.dart';
import 'package:social_app/core/constants/app_colors.dart';
import 'package:social_app/core/constants/app_borders.dart';
import 'package:social_app/core/constants/app_strings.dart';
import 'package:social_app/core/constants/app_paddings.dart';
import '../../../../../core/data/models/message_result.dart';
import 'package:social_app/core/data/models/post_model.dart';
import '../../../../../core/data/models/paginated_posts.dart';
import 'package:social_app/core/constants/app_text_styles.dart';
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
    _buildViewImages(postsImages, ProfileStrings.postsImages),
    _buildViewImages(profilePictures, ProfileStrings.profilePictures),
    _buildViewImages(coverPhotos, ProfileStrings.coverPhotos),
  ];

  ViewImages _buildViewImages(List<PostModel> images, String title) {
    return ViewImages(
      onAdd: widget.onAdd,
      onUpsert: widget.onUpsert,
      onRemove: widget.onRemove,
      onToggle: widget.onToggle,
      imagesList: images,
      messageResult: widget.messageResult,
      title: title,
    );
  }

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
        padding: AppPaddings.xs,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min, // Important change
          children: [
            Padding(
              padding: AppPaddings.onlyTop10,
              child: Text(
                "Albums",
                style: AppTextStyles.boldLarge,
              ),
            ),
            Padding(
              padding: AppPaddings.onlyTop20,
              child: SizedBox(
                height: AppSizes.size220,
                child: AlbumsList(
                  albumsButtons: _albumsButtons,
                  onPressed: (index) {
                    widget.changeIndex(index);
                  },
                  currentIndex: widget.currentIndex,
                ),
              ),
            ),
            Container(height: 1.0, color: AppColors.grey),
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
      padding: AppPaddings.xs,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AspectRatio(
            aspectRatio: 1,
            child: Container(
              height: AppSizes.size180,
              decoration: BoxDecoration(
                borderRadius: AppBorders.borderRadius_10,
                border: Border.all(color: AppColors.white70),
              ),
              child: InkWell(
                onTap: onPressed,
                child: ClipRRect(
                  borderRadius: AppBorders.borderRadius_10,
                  child: albumIButtons.imagesListIsNotEmpty
                      ? Image.network(
                    albumIButtons.userPost ?? AppStrings.empty,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: AppColors.grey,
                        child: const Icon(Icons.image),
                      );
                    },
                  )
                      : SizedBox.shrink(),
                ),
              ),
            ),
          ),
          AppSpaces.vertical_8,
          Text(
            albumIButtons.albumText,
            style: AppTextStyles.boldMedium,
          ),
        ],
      ),
    );
  }
}