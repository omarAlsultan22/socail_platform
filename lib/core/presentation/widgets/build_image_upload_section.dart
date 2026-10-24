import 'dart:io';
import 'package:flutter/material.dart';
import '../../data/models/post_model.dart';
import 'package:social_app/core/constants/app_sizes.dart';
import '../../services/domain/i_media_upload_service.dart';
import 'package:social_app/core/constants/app_borders.dart';
import 'package:social_app/core/constants/app_strings.dart';
import 'package:social_app/core/constants/app_paddings.dart';
import 'package:social_app/core/presentation/screens/publishing_confirmation_screen.dart';


class BuildImageUploadSection<T> extends StatefulWidget {
  final String uId;
  final PostModel postModel;
  final void Function(PostModel) onTap;
  final IMediaUploadService mediaUploadService;
  const BuildImageUploadSection({
    super.key,
    required this.uId,
    required this.onTap,
    required this.postModel,
    required this.mediaUploadService
  });

  @override
  State<BuildImageUploadSection<T>> createState() => _BuildImageUploadSection<T>();
}

class _BuildImageUploadSection<T> extends State<BuildImageUploadSection<T>> {
  late PostModel _postModel;

  void _setMedia(File file, String pathType) {
    setState(() {
      _postModel = widget.postModel.copyWith(
          file: file,
          pathType: pathType,
          userPost: file.path
      );
    });
    widget.onTap(_postModel);
  }

  Future<void> _showMediaPicker(BuildContext context) async {
    await showModalBottomSheet(
      context: context,
      builder: (context) =>
          SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.photo_library),
                  title: const Text('Image from the exhibition'),
                  onTap: () async {
                    Navigator.pop(context);
                    final file = await widget.mediaUploadService.pickImage();
                    _setMedia(file!, AppStrings.image);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.video_library),
                  title: const Text('Video from the exhibition'),
                  onTap: () async {
                    Navigator.pop(context);
                    final file = await widget.mediaUploadService.pickVideo();
                    _setMedia(file!, AppStrings.video);
                  },
                ),
              ],
            ),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: AppPaddings.all10,
      child: _postModel.userPostIsEmpty ?
      InkWell(
        onTap: () async =>
            _showMediaPicker(context),
        child: Container(
            height: AppSizes.size200,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: AppBorders.borderRadius_10,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.photo_library, size: AppSizes.xl),
                    Icon(Icons.video_collection, size: AppSizes.xl),
                  ],
                ),
                const Text('Add photos/videos'),
              ],
            )
        ),
      )
          : Container(
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: AppBorders.borderRadius_10,
        ),
        child: Column(
          children: [
            if(_postModel.userText != null &&
                _postModel.myId != widget.uId)...[
              Padding(
                padding: AppPaddings.onlyLeft15,
                child: Text(
                  _postModel.userText ?? '',
                  style: const TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ),
            ],
            if(!_postModel.userPostIsEmpty)...[
              _postModel.pathType == AppStrings.image ?
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: _postModel.file != null ? FileImage(_postModel.file!) :
                      NetworkImage(_postModel.userPost),
                      fit: BoxFit.cover,
                    ),
                  ),
                  height: AppSizes.size350,
                  width: double.infinity,
                ),
              ) : Expanded(child:
              PublishingConfirmationScreen(
                  file: _postModel.file!)),
            ]
          ],
        ),
      ),
    );
  }
}