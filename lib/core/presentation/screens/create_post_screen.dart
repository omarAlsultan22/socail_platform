import 'package:flutter/cupertino.dart';
import '../../data/models/post_model.dart';
import '../widgets/build_submit_button.dart';
import '../widgets/build_user_info_section.dart';
import '../widgets/build_post_input_section.dart';
import '../widgets/build_image_upload_section.dart';
import 'package:social_app/core/data/models/message_result.dart';
import 'package:social_app/features/public/data/models/user_details.dart';
import 'package:social_app/core/presentation/screens/split_screen.dart';


class CreatePostScreen extends StatefulWidget {
  final String currentId;
  final String titleName;
  final String buttonName;
  final PostModel? postModel;
  final UserDetails userDetails;
  final MessageResult messageResult;
  final Function(PostModel) onPressed;

  const CreatePostScreen({
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
  late PostModel _postModel;
  final textController = TextEditingController();
  String? selectedValue;

  @override
  void initState() {
    super.initState();
    _postModel = widget.postModel ?? PostModel();
    if (_postModel.myId == widget.currentId) {
      textController.text = _postModel.userText ?? '';
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
        postModel: _postModel,
        onTap: (postModel) => setState(() => _postModel = postModel),
      ),
      buildSubmitButton: BuildSubmitButton(
        folderName: 'posts',
        state: selectedValue,
        postModel: _postModel,
        currentId: widget.currentId,
        onPressed: widget.onPressed,
        buttonName: widget.buttonName,
        textController: textController,
        messageResult: widget.messageResult,
      ),
    );
  }
}