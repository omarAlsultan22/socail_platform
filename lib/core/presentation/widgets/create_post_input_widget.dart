import 'package:flutter/material.dart';
import 'package:social_app/core/data/models/post_model.dart';
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
                padding: const EdgeInsets.symmetric(vertical: 10.0),
                child: TextButton(
                    style: ButtonStyle(
                      shape: MaterialStateProperty.all<
                          RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50.0),
                        ),
                      ),
                      backgroundColor: MaterialStateProperty.all(
                          Colors.transparent),
                      overlayColor: MaterialStateProperty.all(
                          Colors.black12),
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
                            borderRadius: BorderRadius.circular(50.0),
                            border: Border.all(
                                color: Colors.grey) // Rounded corners
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: Row(
                              children: [
                                ClipOval(
                                  child: Material(
                                    color: Colors.transparent,
                                    child: SizedBox(
                                      width: 50.0,
                                      height: 50.0,
                                      child: (!userDetails.myImageUrlIsEmpty) ?
                                      Image.network(
                                        userDetails.myImageUrl,
                                        fit: BoxFit.cover,
                                      ) : Icon(Icons.person, size: 50.0),
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
                                    color: Colors.grey.shade700,
                                    child: SizedBox(
                                      width: 50.0,
                                      height: 50.0,
                                      child: Icon(
                                        Icons.image,
                                        size: 30.0,
                                        color: Colors.white,
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