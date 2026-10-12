import '../service _locator.dart';
import '../../../features/interactions/comments/domain/use_cases/add_comment_use_case.dart';
import 'package:social_app/features/interactions/likes/presentation/cubits/likes_cubit.dart';
import '../../../features/interactions/likes/domain/use_cases/get_likes_stream_use_case.dart';
import 'package:social_app/features/interactions/shares/presentation/cubits/shares_cubit.dart';
import '../../../features/interactions/comments/domain/use_cases/remove_comment_use_case.dart';
import '../../../features/interactions/shares/domain/use_cases/get_shares_stream_use_case.dart';
import '../../../features/interactions/comments/domain/use_cases/add_comment_like_use_case.dart';
import '../../../features/interactions/comments/data/datasources/comments_remote_datasource.dart';
import 'package:social_app/features/interactions/comments/presentation/cubits/comments_cubit.dart';
import '../../../features/interactions/comments/data/repository_impl/comments_repository_impl.dart';
import '../../../features/interactions/comments/domain/use_cases/delete_comment_like_use_case.dart';
import '../../../features/interactions/comments/domain/use_cases/get_comments_stream_use_case.dart';
import 'package:social_app/features/interactions/likes/data/datasources/likes_remote_datasource.dart';
import 'package:social_app/features/interactions/shares/data/datasources/shares_remote_datasource.dart';
import 'package:social_app/features/interactions/likes/data/repository_impl/firestor_likes_repository.dart';
import 'package:social_app/features/interactions/shares/data/repository_impl/firestor_shares_repository.dart';
import 'package:social_app/features/interactions/comments_likes/presentation/cubits/comments_likes_cubit.dart';
import '../../../features/interactions/comments_likes/domain/use_cases/get_comment_likes_stream_use_case.dart';
import 'package:social_app/features/interactions/comments_likes/data/datasources/comments_likes_remote_datasource.dart';
import 'package:social_app/features/interactions/comments_likes/data/repository_impl/comments_likes_repository_impl.dart';


class InteractionsDependencies {
  static void register() {
    // Repositories
    sl.registerLazySingleton(() =>
        LikesRepositoryImpl(
            remoteDataSource: sl<LikesRemoteDataSourceImpl>()
        )
    );

    sl.registerLazySingleton(() =>
        CommentsRepositoryImpl(
            remoteDataSource: sl<CommentsRemoteDataSourceImpl>()
        )
    );

    sl.registerLazySingleton(() =>
        CommentsLikesRepositoryImpl(
            remoteDataSource: sl<CommentsLikesRemoteDataSourceImpl>()
        )
    );

    sl.registerLazySingleton(() =>
        SharesRepositoryImpl(remoteDataSource: sl<SharesRemoteDataSource>()
        )
    );

    // UseCases
    sl.registerLazySingleton(() =>
        GetLikesStreamUseCase(repository: sl<LikesRepositoryImpl>())
    );
    sl.registerLazySingleton(() =>
        AddCommentUseCase(repository: sl<CommentsRepositoryImpl>())
    );
    sl.registerLazySingleton(() =>
        RemoveCommentUseCase(repository: sl<CommentsRepositoryImpl>())
    );
    sl.registerLazySingleton(() =>
        AddCommentLikeUseCase(repository: sl<CommentsRepositoryImpl>())
    );
    sl.registerLazySingleton(() =>
        DeleteCommentLikeUseCase(repository: sl<CommentsRepositoryImpl>())
    );
    sl.registerLazySingleton(() =>
        GetCommentsStreamUseCase(repository: sl<CommentsRepositoryImpl>())
    );
    sl.registerLazySingleton(() =>
        GetCommentLikesStreamUseCase(repository: CommentsLikesRepositoryImpl(
            remoteDataSource: sl<CommentsLikesRemoteDataSourceImpl>()
        )));
    sl.registerLazySingleton(() =>
        GetSharesStreamUseCase(repository: SharesRepositoryImpl(
            remoteDataSource: sl<SharesRemoteDataSourceImpl>()
        )
        )
    );

    // Cubits
    sl.registerFactory(() =>
        CommentsCubit(
            addCommentUseCase: sl<AddCommentUseCase>(),
            removeCommentUseCase: sl<RemoveCommentUseCase>(),
            addCommentLikeUseCase: sl<AddCommentLikeUseCase>(),
            deleteCommentLikeUseCase: sl<DeleteCommentLikeUseCase>(),
            getCommentsStreamUseCase: sl<GetCommentsStreamUseCase>()
        )
    );

    sl.registerFactory(() =>
        LikesCubit(getLikesStreamUseCase: sl<GetLikesStreamUseCase>())
    );

    sl.registerFactory(() =>
        SharesCubit(getSharesStreamUseCase: sl<GetSharesStreamUseCase>())
    );

    sl.registerFactory(() =>
        CommentsLikesCubit(
            getCommentLikesStreamUseCase: sl<GetCommentLikesStreamUseCase>())
    );
  }
}