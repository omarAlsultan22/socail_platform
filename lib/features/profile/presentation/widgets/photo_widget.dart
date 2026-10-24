import 'package:flutter/material.dart';
import '../../../../core/di/service _locator.dart';
import '../../../../core/data/models/post_model.dart';
import '../../../public/data/models/user_details.dart';
import 'package:social_app/core/constants/app_sizes.dart';
import 'package:social_app/core/constants/app_colors.dart';
import 'package:social_app/core/constants/app_borders.dart';
import 'package:social_app/core/data/models/message_result.dart';
import 'package:social_app/core/services/data/session_service.dart';
import '../../../../core/presentation/screens/view_post_screen.dart';
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
        borderRadius: AppBorders.borderRadius_8,
        child: Image(
          image: NetworkImage(data.userPost),
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              height: AppSizes.size200,
              width: AppSizes.size200,
              color: AppColors.grey,
              child: const Icon(Icons.image),
            );
          },
        ),
      ),
    );
  }
}