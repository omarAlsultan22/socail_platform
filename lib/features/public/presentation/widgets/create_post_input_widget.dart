import 'package:social_app/features/public/presentation/screens/create_post_screen.dart';

import '../../../profile/cubit.dart';
import 'package:flutter/material.dart';
import 'package:social_app/core/constants/user_details.dart';
import '../../../../shared/componentes/post_components.dart';


class PostCreationWidget extends StatelessWidget {
  final BuildContext context;

  const PostCreationWidget({
    required this.context,
    super.key,
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
                        onPressed: (postModel) {
                          HomeCubit
                              .get(context).insertAndUpdatePosts(postModel: postModel);
                          ProfileCubit.get(context)
                              .insertAndUpdatePosts(postModel:
                          postModel);
                        }
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
                            child:  UserDetails.image.isNotEmpty?
                            Image.network(
                              UserDetails.image,
                              fit: BoxFit.cover,
                            ) : Icon(Icons.person),
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