import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/presentation/coordinators/post_syncable.dart';
import '../../features/profile/presentation/cubits/posts_cubit.dart';
import '../../features/public/presentation/cubits/public_cubit.dart';
import '../../features/profile/presentation/cubits/photos_cubit.dart';
import '../../features/profile/presentation/cubits/videos_cubit.dart';
import '../../features/profile/presentation/cubits/my_profile_cubit.dart';


class PostSyncGroups {
  static List<PostSyncable> all(BuildContext context) => [
    context.read<PostsCubit>(),
    context.read<PublicCubit>(),
    context.read<PhotosCubit>(),
    context.read<VideosCubit>(),
    context.read<MyProfileCubit>(),
  ];

  static List<PostSyncable> photo(BuildContext context) => [
    context.read<PostsCubit>(),
    context.read<PublicCubit>(),
    context.read<PhotosCubit>(),
    context.read<MyProfileCubit>(),
  ];

  static List<PostSyncable> video(BuildContext context) => [
    context.read<PostsCubit>(),
    context.read<PublicCubit>(),
    context.read<VideosCubit>(),
  ];
}
