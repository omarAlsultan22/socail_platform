import 'package:flutter/material.dart';
import 'package:social_app/core/constants/app_sizes.dart';
import 'package:social_app/core/constants/app_colors.dart';
import 'package:social_app/core/constants/app_borders.dart';
import 'package:social_app/core/data/models/post_model.dart';
import 'package:social_app/core/constants/app_paddings.dart';
import 'package:social_app/core/data/models/message_result.dart';
import 'package:social_app/core/presentation/screens/create_post_screen.dart';
import 'package:social_app/core/presentation/widgets/navigation/navigator.dart';
import 'package:social_app/core/presentation/widgets/current_user_selector.dart';


class PostCreationWidget extends StatelessWidget {
  final String uId;
  final MessageResult messageResult;
  final void Function(PostModel) onUpsert;

  const PostCreationWidget({
    super.key,
    required this.uId,
    required this.onUpsert,
    required this.messageResult
  });

  @override
  Widget build(BuildContext context) {
    return CurrentUserSelector(
        builder: (userDetails) =>
            Padding(
                padding: AppPaddings.symmetricVertical10,
                child: TextButton(
                    style: ButtonStyle(
                      shape: MaterialStateProperty.all<
                          RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: AppBorders.borderRadius_50,
                        ),
                      ),
                      backgroundColor: MaterialStateProperty.all(
                          AppColors.transparent),
                      overlayColor: MaterialStateProperty.all(
                          AppColors.black12),
                      padding: MaterialStateProperty.all(
                          EdgeInsets.zero), // Remove default padding
                    ),
                    onPressed: () {
                      BuildNavigator.build(
                          context: context,
                          link: CreatePostScreen(
                            titleName: 'Create Post',
                            buttonName: 'Post',
                            currentId: uId,
                            userDetails: userDetails,
                            onPressed: (postModel) =>
                                onUpsert(postModel),
                            messageResult: messageResult,
                          )
                      );
                    },
                    child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                            borderRadius: AppBorders.borderRadius_50,
                            border: Border.all(
                                color: AppColors.grey) // Rounded corners
                        ),
                        child: Padding(
                          padding: AppPaddings.all5,
                          child: Row(
                              children: [
                                ClipOval(
                                  child: Material(
                                    color: AppColors.transparent,
                                    child: SizedBox(
                                      width: AppSizes.xl,
                                      height: AppSizes.xl,
                                      child: (!userDetails.myImageUrlIsEmpty) ?
                                      Image.network(
                                        userDetails.myImageUrl,
                                        fit: BoxFit.cover,
                                      ) : Icon(Icons.person, size: AppSizes.xl),
                                    ),
                                  ),
                                ),
                                // Text Prompt
                                const Expanded(
                                  child: Center(
                                    child: Text(
                                      'Do you want to write anything?',
                                      style: TextStyle(
                                        fontSize: 18.0,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                                ClipOval(
                                  child: Material(
                                    color: AppColors.grey700,
                                    child: SizedBox(
                                      width: AppSizes.xl,
                                      height: AppSizes.xl,
                                      child: Icon(
                                        Icons.image,
                                        size: AppSizes.size30,
                                        color: AppColors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ]
                          ),
                        )
                    )
                )
            )
    );
  }
}