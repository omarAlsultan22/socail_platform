import 'package:flutter/cupertino.dart';
import '../../data/models/post_model.dart';
import '../widgets/new/build_submit_button.dart';
import '../widgets/new/build_user_info_section.dart';
import '../widgets/new/build_post_input_section.dart';
import '../widgets/new/build_image_upload_section.dart';
import 'package:social_app/core/data/models/message_result.dart';
import 'package:social_app/features/public/data/models/user_details.dart';
import 'package:social_app/core/presentation/widgets/new/split_screen.dart';


class CreatePostScreen extends StatefulWidget {
  PostModel? postModel;
  final String currentId;
  final String titleName;
  final String buttonName;
  final UserDetails userDetails;
  Function(PostModel) onPressed;
  final MessageResult messageResult;

  CreatePostScreen({
    super.key,
    this.postModel,
    required this.currentId,
    required this.onPressed,
    required this.titleName,
    required this.buttonName,
    required this.userDetails,
    required this.messageResult
  });

  @override
  State<CreatePostScreen> createState() => _CreatePostState();
}

class _CreatePostState extends State<CreatePostScreen> {
  final textController = TextEditingController();
  String? selectedValue;

  @override
  void initState() {
    super.initState();
    widget.postModel ??= PostModel();
    if (widget.postModel!.myId == widget.currentId) {
      textController.text = widget.postModel!.userText ?? '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return SplitScreen(
      titleName: widget.titleName,
      buildUserInfoSection: BuildUserInfoSection(
        myName: widget.userDetails.myName,
        myImageUrl: widget.userDetails.myImageUrl,
        onPressed: (value) =>
            setState(() =>
            selectedValue = value),
      ),
      buildPostInputSection: BuildPostInputSection(
          textController: textController),
      buildImageUploadSection: BuildImageUploadSection(
        uId: widget.currentId,
        postModel: widget.postModel,
        onTap: (postModel) => setState(() => widget.postModel = postModel),
      ),
      buildSubmitButton: BuildSubmitButton(
        folderName: 'posts',
        state: selectedValue,
        currentId: widget.currentId,
        onPressed: widget.onPressed,
        postModel: widget.postModel,
        buttonName: widget.buttonName,
        textController: textController,
        messageResult: widget.messageResult,
      ),
    );
  }
}