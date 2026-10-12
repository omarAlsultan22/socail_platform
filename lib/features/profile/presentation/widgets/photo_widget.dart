import 'package:flutter/material.dart';
import '../../../../core/di/service _locator.dart';
import '../../../../core/data/models/post_model.dart';
import '../../../public/data/models/user_details.dart';
import 'package:social_app/core/services/session_service.dart';
import 'package:social_app/core/data/models/message_result.dart';
import '../../../../core/presentation/widgets/new/view_post_screen.dart';
import 'package:social_app/core/presentation/widgets/navigation/navigator.dart';


class PhotoWidget extends StatelessWidget {
  final PostModel data;
  final UserDetails userDetails;
  final MessageResult messageResult;
  final void Function(PostModel) onAdd;
  final void Function(PostModel) onUpsert;
  final void Function(PostModel) onRemove;
  final void Function(bool, PostModel) onToggle;

  const PhotoWidget({
    super.key,
    required this.data,
    required this.onAdd,
    required this.onUpsert,
    required this.onRemove,
    required this.onToggle,
    required this.userDetails,
    required this.messageResult,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () =>
          BuildNavigator.build(
              context: context,
              link: ViewPostScreen(
                onAdd: onAdd,
                postModel: data,
                onToggle: onToggle,
                onUpsert: onUpsert,
                onRemove: onRemove,
                userDetails: userDetails,
                messageResult: messageResult,
                sessionService: sl<SessionService>(),
              )
          ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8.0),
        child: Image(
          image: NetworkImage(data.userPost ?? ''),
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              height: 200.0,
              width: 200.0,
              color: Colors.grey,
              child: const Icon(Icons.image),
            );
          },
        ),
      ),
    );
  }
}