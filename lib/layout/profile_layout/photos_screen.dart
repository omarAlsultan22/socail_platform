import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_app/models/post_model.dart';
import 'package:social_app/modules/profile_screen/cubit.dart';
import 'package:social_app/shared/cubit_states/cubit_states.dart';
import '../../shared/componentes/post_components.dart';

class PhotosScreen extends StatefulWidget {
  final ProfileCubit profileCubit;
  PhotosScreen({
    required this.profileCubit,
    super.key});

  @override
  State<PhotosScreen> createState() => _PhotosScreenState();
}

class _PhotosScreenState extends State<PhotosScreen> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final userId =  widget.profileCubit.userId;
    widget.profileCubit
      ..getProfileImages(userId: userId)
      ..getCoverImages(userId: userId);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileCubit, CubitStates>(
      builder: (context, state) {
        final coverImages = widget.profileCubit.coverImagesList;
        final profileImages = widget.profileCubit.profileImagesList;
        final postsImages = widget.profileCubit.postsDataList;

        if (state is LoadingState) {
          return const Center(child: CircularProgressIndicator());
        }

        if (coverImages.isEmpty && profileImages.isEmpty &&
            postsImages.isEmpty) {
          return const Center(child: Text('No images available'));
        }

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
                      albumsButtons: widget.profileCubit.albumsButtons,
                      onPressed: (index) {
                        widget.profileCubit.changeIndex(index);
                      },
                      currentIndex: widget.profileCubit.currentIndex,
                    ),
                  ),
                ),
                Container(height: 1.0, color: Colors.grey),
                widget.profileCubit.albumsScreens[widget.profileCubit.currentIndex],
              ],
            ),
          ),
        );
      },
    );
  }
}

Widget myPhotos(PostModel data, BuildContext context) => InkWell(
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ViewImage(
          postModel: data,
        ),
      ),
    );
  },
  child: ClipRRect(
    borderRadius: BorderRadius.circular(8.0),
    child: Image(
      image: NetworkImage(data.userPost!),
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          height: 200.0,
          width: 200.0,
          color: Colors.grey,
          child: const Icon(Icons.error),
        );
      },
    ),
  ),
);

Text title({required String title}) => Text(
  title,
  style: const TextStyle(
    fontSize: 18.0,
    fontWeight: FontWeight.bold,
  ),
);


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
  final AlbumsButtons albumIButtons;
  final VoidCallback onPressed;

  const AlbumLayout({
    required this.albumIButtons,
    required this.onPressed,
    super.key,
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
                  child: albumIButtons.albumImage != null
                      ? Image.network(
                    albumIButtons.albumImage!.userPost!,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey,
                        child: const Icon(Icons.error),
                      );
                    },
                  )
                      : Container(
                    color: Colors.grey,
                    child: const Icon(Icons.image),
                  ),
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

class ImagesScreen extends StatelessWidget {
  late List<PostModel> postModelList;
  final String titleName;

  ImagesScreen({
    required this.postModelList,
    required this.titleName,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ViewImages(
      postModelList: postModelList,
      titleName: titleName,
    );
  }
}

class ViewImages extends StatelessWidget {
  final List<PostModel> postModelList;
  final String titleName;

  const ViewImages({
    required this.postModelList,
    required this.titleName,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(height: 1.0, color: Colors.grey),
        Padding(
          padding: const EdgeInsets.only(top: 20.0),
          child: Text(
            titleName,
            style: const TextStyle(
              fontSize: 18.0,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 20.0),
          child: postModelList.isEmpty
              ? const Padding(
            padding: EdgeInsets.all(20.0),
            child: Text('No images available in this album'),
          )
              : GridView.count(
            crossAxisCount: 3,
            shrinkWrap: true,
            crossAxisSpacing: 5.0,
            mainAxisSpacing: 5.0,
            physics: const NeverScrollableScrollPhysics(),
            children: postModelList
                .map((e) => myPhotos(e, context))
                .toList(),
          ),
        ),
      ],
    );
  }
}