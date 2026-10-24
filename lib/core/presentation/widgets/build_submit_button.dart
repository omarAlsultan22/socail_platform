import 'package:flutter/material.dart';
import '../../data/models/post_model.dart';
import '../../services/domain/i_media_upload_service.dart';
import 'package:social_app/core/constants/app_colors.dart';
import 'package:social_app/core/constants/app_strings.dart';
import 'package:social_app/core/data/models/user_model.dart';
import 'package:social_app/core/constants/app_constants.dart';
import 'package:social_app/core/data/models/message_result.dart';
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
  final IMediaUploadService mediaUploadService;
  const BuildSubmitButton({
    super.key,
    required this.currentId,
    required this.state,
    required this.postModel,
    required this.onPressed,
    required this.folderName,
    required this.buttonName,
    required this.messageResult,
    required this.textController,
    required this.mediaUploadService
  });

  @override
  State<BuildSubmitButton> createState() => _BuildSubmitButtonState();
}

class _BuildSubmitButtonState extends State<BuildSubmitButton> {
  // ===== ثوابت خاصة بالملف =====
  static const Color _errorColor = AppColors.red700;

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
        (widget.postModel!.userPostIsEmpty)) {
      BuildSnackBar.show(
          context: context,
          backgroundColor: _errorColor,
          message: 'Please enter post details or add an image'
      );
      return;
    }

    if (widget.postModel!.myId == widget.currentId &&
        widget.buttonName == AppStrings.shareNow) {
      BuildSnackBar.show(
        context: context,
        backgroundColor: _errorColor,
        message: 'You cannot share your post',
      );
      return;
    }

    if (widget.postModel!.myId != widget.currentId &&
        widget.buttonName == AppStrings.shareNow) {
      late PostModel newPostModel;
      setState(() =>
      newPostModel = PostModel(
        meIsOnline: true,
        postIsShared: true,
        myDateTime: DateTime.now(),
        userPost: widget.postModel!.userPost,
        myState: widget.state ?? AppConstants.defaultState,
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
      final map = await widget.mediaUploadService.checkAndUploadFile(
          widget.postModel!.file!);
      final newPostModel = widget.postModel!.copyWith(
        meIsOnline: true,
        dateTime: DateTime.now(),
        userPost: map!['url'] ?? '',
        pathType: map['type'] ?? '',
        myState: widget.state ?? AppConstants.defaultState,
        userText: widget.textController.text,
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
          color: AppColors.primaryBlue,
          child: widget.messageResult.isLoading ?
          Center(child: CircularProgressIndicator(
              color: AppColors.white)) :
          Text(
            widget.buttonName,
            style: const TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.bold,
                color: AppColors.white
            ),
          )
      ),
    );
  }
}