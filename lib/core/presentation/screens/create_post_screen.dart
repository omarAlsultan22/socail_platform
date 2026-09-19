import 'package:flutter/cupertino.dart';
import '../../data/models/post_model.dart';
import '../widgets/new/build_submit_button.dart';
import '../widgets/new/build_user_info_section.dart';
import '../widgets/new/build_post_input_section.dart';
import '../widgets/new/build_image_upload_section.dart';
import 'package:social_app/core/presentation/widgets/new/split_screen.dart';


class CreatePostScreen extends StatefulWidget {
  final String uId;
  PostModel? postModel;
  final String titleName;
  final String buttonName;
  Function(PostModel) onPressed;

  CreatePostScreen({
    super.key,
    this.postModel,
    required this.buttonName,
    required this.titleName,
    required this.onPressed,
    required this.uId
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
    if (widget.postModel!.userId == widget.uId) {
      textController.text = widget.postModel!.userText ?? '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return SplitScreen(
      titleName: widget.titleName,
      buildUserInfoSection: BuildUserInfoSection(
        onPressed: (value) =>
            setState(() =>
            selectedValue = value
            ),
      ),
      buildPostInputSection: BuildPostInputSection(
          textController: textController),
      buildImageUploadSection: BuildImageUploadSection(
        uId: widget.uId,
        postModel: widget.postModel,
        onTap: (postModel) => setState(() => widget.postModel = postModel),
      ),
      buildSubmitButton: BuildSubmitButton(
        uId: widget.uId,
        state: selectedValue,
        postModel: widget.postModel,
        folderName: 'posts',
        buttonName: widget.buttonName,
        textController: textController,
        onPressed: (postModel) => widget.onPressed(postModel),
      ),
    );
  }
}