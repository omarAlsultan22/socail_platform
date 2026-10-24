import 'package:flutter/material.dart';
import 'package:social_app/core/constants/app_paddings.dart';


class SplitScreen extends StatelessWidget {
  final String titleName;
  final Widget buildUserInfoSection;
  final Widget buildPostInputSection;
  final Widget buildImageUploadSection;
  final Widget buildSubmitButton;

  const SplitScreen({
    required this.titleName,
    required this.buildUserInfoSection,
    required this.buildPostInputSection,
    required this.buildImageUploadSection,
    required this.buildSubmitButton,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(child: Text(titleName)),
      ),
      body: Padding(
        padding: AppPaddings.xs,
        child: Column(
          children: [
            buildUserInfoSection,
            buildPostInputSection,
            Expanded(child: buildImageUploadSection),
            buildSubmitButton,
          ],
        ),
      ),
    );
  }
}