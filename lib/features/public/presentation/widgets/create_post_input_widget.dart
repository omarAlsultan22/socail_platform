import 'package:flutter/material.dart';
import '../../../../core/di/service _locator.dart';
import 'package:social_app/core/data/models/post_model.dart';
import 'package:social_app/core/services/session_service.dart';
import 'package:social_app/core/presentation/screens/create_post_screen.dart';


class PostCreationWidget extends StatelessWidget {
  final String? userImage;
  final void Function(PostModel) insertAndUpdatePublicPosts;
  final void Function(PostModel) insertAndUpdateProfilePosts;
  const PostCreationWidget({
    super.key,
    this.userImage,
    required this.insertAndUpdatePublicPosts,
    required this.insertAndUpdateProfilePosts
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
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
            Navigator.push(
                context, MaterialPageRoute(
                builder: (context) =>
                    CreatePostScreen(
                      titleName: 'Create Post',
                      buttonName: 'Post',
                      uId: sl<SessionService>(),
                      onPressed: (postModel) {
                        insertAndUpdatePublicPosts(postModel);
                        insertAndUpdateProfilePosts(postModel);
                      },
                    )
            )
            );
          },
          child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(50.0),
                  border: Border.all(color: Colors.grey) // Rounded corners
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
                            child:  (userImage != null && userImage!.isNotEmpty)?
                            Image.network(
                              userImage!,
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
      ),
    );
  }
}