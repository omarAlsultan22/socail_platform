import '../../../../core/data/models/post_model.dart';


class AlbumsButtons {
  final int id;
  final String albumText;
  final List<PostModel> albumImages;

  const AlbumsButtons({
    required this.id,
    required this.albumImages,
    required this.albumText,
  });

  PostModel get firstModel => albumImages.first;
  String? get userPost => firstModel.userPost;
  bool get imagesListIsNotEmpty => albumImages.isNotEmpty;
}