import 'package:flutter/material.dart';
import '../../../data/models/post_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:social_app/core/services/session_service.dart';
import 'package:social_app/core/services/media_picker_service.dart';


class BuildSubmitButton extends StatefulWidget {
  final String uId;
  final String? state;
  PostModel? postModel;
  final String folderName;
  final String buttonName;
  final void Function(PostModel) onPressed;
  final TextEditingController textController;
  BuildSubmitButton({
    super.key,
    required this.uId,
    required this.state,
    required this.postModel,
    required this.onPressed,
    required this.folderName,
    required this.buttonName,
    required this.textController
  });

  @override
  State<BuildSubmitButton> createState() => _BuildSubmitButtonState();
}

class _BuildSubmitButtonState extends State<BuildSubmitButton> {
  bool isLoading = false;

  void setData() async {
    try {
      setState(() => isLoading = true);

      if ((widget.textController.text.isEmpty || widget.textController.text.trim() == '') &&
          (widget.postModel!.userPost == null || widget.postModel!.userPost!.isEmpty)) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Please enter post details or add an image'),
          backgroundColor: Colors.red.shade700,
        ));
        return;
      }

      if(widget.postModel!.userId == widget.uId && widget.buttonName == 'Share Now'){
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('You cannot share your post'),
          backgroundColor: Colors.red.shade700,
        ));
        return;
      }

      if(widget.postModel!.userId != widget.uId && widget.buttonName == 'Share Now') {
        final newPostModel = PostModel();
        final docId = await createDoc();
        setState(() =>
        newPostModel.copyWith(
          docId: docId,
          userPost: widget.postModel!.userPost,
          userState: widget.state ?? 'public',
          userText: widget.textController.text,
          pathType: widget.postModel!.pathType,
          postType: widget.postModel!.postType,
          isOnline: true,
          dateTime: DateTime.now(),
            friendId: widget.postModel!.userId,
            friendName: widget.postModel!.userName,
            friendImage: widget.postModel!.userImage,
            friendText: widget.postModel!.userText,
            friendState: widget.postModel!.userState,
            friendIsOnline: widget.postModel!.isOnline,
            originalDateTime: widget.postModel!.dateTime,
          videoController: widget.postModel!.videoController,
          sharesNumber: 0,
          likesNumber: 0,
          commentsNumber: 0
        ));
        widget.onPressed(newPostModel);
      }
      else {
        final map = await MediaPickerService.checkFile(widget.postModel!.file!);
        final docId = await createDoc();
        setState(() =>
        widget.postModel = PostModel(
            docId: docId,
            userText: widget.textController.text,
            userPost: map!['url'] ?? '',
            userState: widget.state ?? 'public',
            pathType: widget.postModel!.pathType ?? map['type'],
            dateTime: DateTime.now(),
            isOnline: true
        )
        );
        widget.onPressed(widget.postModel!);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(/
          content: Text('The post has been published successfully'),
          backgroundColor: Colors.green.shade700,
        ));
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(/
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red.shade700,
        ));
      }
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      child: MaterialButton(
          onPressed: () => setData(),
          color: Colors.blue.shade900,
          child: isLoading ?
          Center(child: CircularProgressIndicator(
              color: Colors.white)) :
          Text(
            widget.buttonName,
            style: const TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.bold,
                color: Colors.white
            ),
          )
      ),
    );
  }
  Future<String>createDoc()async{
    return FirebaseFirestore.instance.collection('posts').doc().id;
  }
}