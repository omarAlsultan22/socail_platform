import 'package:flutter/material.dart';
import '../../../data/models/post_model.dart';
import 'package:social_app/core/data/models/user_model.dart';
import 'package:social_app/core/data/models/message_result.dart';
import 'package:social_app/core/services/media_picker_service.dart';
import 'package:social_app/core/presentation/widgets/build_snack_bar.dart';


class BuildSubmitButton extends StatefulWidget {
  final String currentId;
  final String? state;
  final String folderName;
  final String buttonName;
  final PostModel? postModel;
  final MessageResult messageResult;
  final void Function(PostModel) onPressed;
  final TextEditingController textController;
  const BuildSubmitButton({
    super.key,
    required this.currentId,
    required this.state,
    required this.postModel,
    required this.onPressed,
    required this.folderName,
    required this.buttonName,
    required this.messageResult,
    required this.textController
  });

  @override
  State<BuildSubmitButton> createState() => _BuildSubmitButtonState();
}

class _BuildSubmitButtonState extends State<BuildSubmitButton> {
  late String _textValue;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _textValue = widget.textController.text;
  }

  void setButtonLock(bool value) {
    setState(() {
      _isLoading = value;
    });
  }

  void setData() async {
    setButtonLock(false);
    if ((_textValue.isEmpty ||
        widget.textController.text.trim() == '') &&
        (widget.postModel!.userPost == null ||
            widget.postModel!.userPostIsEmpty)) {
      BuildSnackBar.show(
          context: context,
          backgroundColor: Colors.red.shade700,
          message: 'Please enter post details or add an image'
      );
      return;
    }

    if (widget.postModel!.myId == widget.currentId &&
        widget.buttonName == 'Share Now') {
      BuildSnackBar.show(
        context: context,
        backgroundColor: Colors.red.shade700,
        message: 'You cannot share your post',
      );
      return;
    }

    if (widget.postModel!.myId != widget.currentId &&
        widget.buttonName == 'Share Now') {
      late PostModel newPostModel;
      setState(() =>
      newPostModel = PostModel(
        meIsOnline: true,
        postIsShared: true,
        myDateTime: DateTime.now(),
        userPost: widget.postModel!.userPost,
        myState: widget.state ?? 'public',
        userText: widget.textController.text,
        pathType: widget.postModel!.pathType,
        postType: widget.postModel!.postType,
        userModel: UserModel(
          userId: widget.postModel!.myId,
          userText: widget.postModel!.userText,
          userName: widget.postModel!.myName,
          userImage: widget.postModel!.myImageUrl,
          userState: widget.postModel!.myState,
          userDocId: widget.postModel!.myDocId,
          userIsOnline: widget.postModel!.meIsOnline,
          originalDateTime: widget.postModel!.myDateTime,
        ),
        videoController: widget.postModel!.videoController,
      ));
      widget.onPressed(newPostModel);
    }
    else {
      final map = await MediaPickerService.checkFile(widget.postModel!.file!);
      final newPostModel = widget.postModel!.copyWith(
          userText: widget.textController.text,
          userPost: map!['url'] ?? '',
          myState: widget.state ?? 'public',
          pathType: widget.postModel!.pathType ?? map['type'],
          dateTime: DateTime.now(),
          meIsOnline: true
      );
      widget.onPressed(newPostModel);
    }
    setButtonLock(true);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: MaterialButton(
          onPressed: _isLoading ? () => setData() : null,
          color: Colors.blue.shade900,
          child: widget.messageResult.isLoading ?
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
}