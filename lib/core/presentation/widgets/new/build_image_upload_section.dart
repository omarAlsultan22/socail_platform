import 'dart:io';
import 'package:flutter/material.dart';
import '../../../data/models/post_model.dart';
import 'package:social_app/core/constants/user_details.dart';
import 'package:social_app/core/services/media_picker_service.dart';
import 'package:social_app/core/presentation/widgets/new/publishing_confirmation_screen.dart';


class BuildImageUploadSection<T> extends StatefulWidget {
  final PostModel? postModel;
  final void Function(PostModel) onTap;
  const BuildImageUploadSection({
    this.postModel,
    required this.onTap,
    super.key});

  @override
  State<BuildImageUploadSection<T>> createState() => _BuildImageUploadSection<T>();
}

class _BuildImageUploadSection<T> extends State<BuildImageUploadSection<T>> {

  void _setMedia(File file, String pathType) {
    setState(() {
      widget.postModel!
        ..file = file
        ..userPost = file.path
        ..pathType = pathType;
    });
    widget.onTap(widget.postModel!);
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
                    final file = await MediaPickerService.pickImage();
                    _setMedia(file!, 'image');
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.video_library),
                  title: const Text('Video from the exhibition'),
                  onTap: () async {
                    Navigator.pop(context);
                    final file = await MediaPickerService.pickVideo();
                    _setMedia(file!, 'video');
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
      padding: const EdgeInsets.all(10.0),
      child: (widget.postModel == null || widget.postModel!.userPost == null) ?
      InkWell(
        onTap: () async =>
            _showMediaPicker(context),
        child: Container(
            height: 200.0,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.photo_library, size: 50.0),
                    Icon(Icons.video_collection, size: 50.0),
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
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Column(
          children: [
            if(widget.postModel!.userText != null &&
                widget.postModel!.userId != UserDetails.uId)...[
              Padding(
                padding: const EdgeInsets.only(left: 15.0),
                child: Text(
                  widget.postModel!.userText ?? '',
                  style: const TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ),
            ],
            if(widget.postModel!.userPost != null)...[
              widget.postModel!.pathType == 'image' ?
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: widget.postModel!.file != null ? FileImage(widget
                          .postModel!.file!) :
                      NetworkImage(widget.postModel!.userPost!),
                      fit: BoxFit.cover,
                    ),
                  ),
                  height: 350.0,
                  width: double.infinity,
                ),
              ) : Expanded(child: PublishingConfirmationScreen(
                  file: widget.postModel!.file!)),
            ]
          ],
        ),
      ),
    );
  }
}