import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:video_player/video_player.dart';
import '../../modules/profile_screen/cubit.dart';
import '../../shared/cubit_states/cubit_states.dart';
import '../../shared/componentes/post_components.dart';
import '../../shared/componentes/public_components.dart';


class VideosScreen extends StatefulWidget {
  final ProfileCubit profileCubit;
  const VideosScreen({
    required this.profileCubit,
    super.key});

  @override
  State<VideosScreen> createState() => _VideosScreenState();
}

class _VideosScreenState extends State<VideosScreen> {
  VideoPlayerController? _fullScreenVideoController;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final userId = widget.profileCubit.userId;
    widget.profileCubit.getVideosPosts(userId: userId);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileCubit, CubitStates>(
      builder: (context, state) {
        final videosList = widget.profileCubit.videosList;
        return videosList.isNotEmpty ?
        Padding(
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
                  crossAxisCount: 3,
                  shrinkWrap: true,
                  crossAxisSpacing: 5.0,
                  mainAxisSpacing: 5.0,
                  physics: NeverScrollableScrollPhysics(),
                  children: videosList.map((e) =>
                      buildVideoContent(
                          postModel: e,
                          fullScreenVideoController: _fullScreenVideoController,
                          context: context,
                          height: 200.0,
                          width: 200.0,
                      ))
                      .toList(),
                ),
              )
            ],
          ),
        ) : Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  sizedBox(),
                  Text("My videos",
                    style: TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold
                    ),
                  ),
                  sizedBox(),
                  Text('There is no any videos here',
                    style: TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.normal
                    ),
                  ),
                ],
              )
            ]
        );
      },
    );
  }
}




