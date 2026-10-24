import 'package:flutter/material.dart';
import '../../../../core/data/models/post_model.dart';
import 'package:social_app/core/constants/app_colors.dart';
import 'package:social_app/core/constants/app_paddings.dart';
import 'package:social_app/core/constants/app_text_styles.dart';
import 'package:social_app/core/data/models/message_result.dart';
import '../../../../core/presentation/widgets/current_user_selector.dart';
import 'package:social_app/features/profile/presentation/widgets/photo_widget.dart';


class ViewImages extends StatelessWidget {
  final String title;
  final List<PostModel> imagesList;
  final MessageResult messageResult;
  final void Function(PostModel) onAdd;
  final void Function(PostModel) onUpsert;
  final void Function(PostModel) onRemove;
  final void Function(bool, PostModel) onToggle;

  const ViewImages({
    super.key,
    required this.title,
    required this.onAdd,
    required this.onUpsert,
    required this.onRemove,
    required this.onToggle,
    required this.imagesList,
    required this.messageResult
  });

  @override
  Widget build(BuildContext context) {
    return Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(height: 1.0, color: AppColors.grey),
          Padding(
            padding: AppPaddings.onlyTop20,
            child: Text(
              title,
              style: AppTextStyles.boldLarge,
            ),
          ),
          Padding(
              padding: AppPaddings.onlyTop20,
              child: imagesList.isEmpty
                  ? Padding(
                padding: AppPaddings.all20,
                child: Text('No images available in this album'),
              )
                  : GridView.count(
                crossAxisCount: 3,
                shrinkWrap: true,
                crossAxisSpacing: 5.0,
                mainAxisSpacing: 5.0,
                physics: const NeverScrollableScrollPhysics(),
                children: imagesList.map((data) {
                  return CurrentUserSelector(
                      builder: (userDetails) =>
                          PhotoWidget(
                              data: data,
                              onAdd: onAdd,
                              onToggle: onToggle,
                              onUpsert: onUpsert,
                              onRemove: onRemove,
                              userDetails: userDetails,
                              messageResult: messageResult
                          )
                  );
                }).toList(),
              )
          )
        ]
    );
  }
}