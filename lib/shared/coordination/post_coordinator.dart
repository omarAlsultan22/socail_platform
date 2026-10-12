import 'package:flutter/widgets.dart';
import '../../core/data/models/post_model.dart';
import '../../core/presentation/coordinators/post_syncable.dart';


class PostCoordinator {
  static void upsertPost(
      BuildContext context, {
        required PostModel postModel,
        required List<PostSyncable> Function(BuildContext) group,
      }) {
    for (final cubit in group(context)) {
      cubit.upsertPostToList(postModel);
    }
  }

  static void removePost(
      BuildContext context, {
        required PostModel postModel,
        required List<PostSyncable> Function(BuildContext) group,
      }) {
    for (final cubit in group(context)) {
      cubit.removePostFromList(postModel);
    }
  }
}