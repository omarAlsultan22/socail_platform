import '../service _locator.dart';
import '../../services/data/session_service.dart';
import '../../services/domain/i_user_account_service.dart';
import '../../../features/interactions/likes/domain/repository/likes_repository.dart';
import '../../../features/interactions/shares/domain/repository/shares_repository.dart';
import '../../../features/interactions/likes/domain/data_sources/likes_data_source.dart';
import '../../../features/interactions/shares/domain/data_sources/shares_data_source.dart';
import '../../../features/interactions/comments/domain/repository/comments_repository.dart';
import '../../../features/interactions/comments/domain/use_cases/add_comment_use_case.dart';
import '../../../features/interactions/likes/data/data_sources/likes_data_source_impl.dart';
import 'package:social_app/features/interactions/likes/presentation/cubits/likes_cubit.dart';
import '../../../features/interactions/shares/data/data_sources/shares_data_source_impl.dart';
import '../../../features/interactions/likes/domain/use_cases/get_likes_stream_use_case.dart';
import '../../../features/interactions/comments/domain/data_sources/comments_data_source.dart';
import 'package:social_app/features/interactions/shares/presentation/cubits/shares_cubit.dart';
import '../../../features/interactions/comments/domain/use_cases/remove_comment_use_case.dart';
import '../../../features/interactions/shares/domain/use_cases/get_shares_stream_use_case.dart';
import '../../../features/interactions/comments/domain/use_cases/add_comment_like_use_case.dart';
import '../../../features/interactions/comments/data/data_sources/comments_data_source_impl.dart';
import 'package:social_app/features/interactions/comments/presentation/cubits/comments_cubit.dart';
import '../../../features/interactions/comments/data/repository_impl/comments_repository_impl.dart';
import '../../../features/interactions/comments/domain/use_cases/delete_comment_like_use_case.dart';
import '../../../features/interactions/comments/domain/use_cases/get_comments_stream_use_case.dart';
import '../../../features/interactions/comments_likes/domain/repository/comments_likes_repository.dart';
import 'package:social_app/features/interactions/likes/data/repository_impl/likes_repository_impl.dart';
import 'package:social_app/features/interactions/shares/data/repository_impl/shares_repository_impl.dart';
import '../../../features/interactions/comments_likes/domain/data_sources/comments_likes_data_source.dart';
import '../../../features/interactions/comments_likes/data/data_sources/comments_likes_data_source_impl.dart';
import 'package:social_app/features/interactions/comments_likes/presentation/cubits/comments_likes_cubit.dart';
import '../../../features/interactions/comments_likes/domain/use_cases/get_comment_likes_stream_use_case.dart';
import 'package:social_app/features/interactions/comments_likes/data/repository_impl/comments_likes_repository_impl.dart';


class InteractionsDependencies {
  static void register() {
    //DataSource
    sl.registerLazySingleton<LikesDataSource>(() =>
        LikesDataSourceImpl(
            sessionService: sl<SessionService>(),
            userAccountService: sl<IUserAccountService>()
        )
    );

    sl.registerLazySingleton<CommentsDataSource>(() =>
        CommentsDataSourceImpl(
            sessionService: sl<SessionService>(),
            userAccountService: sl<IUserAccountService>()
        )
    );

    sl.registerLazySingleton<CommentsLikesDataSource>(() =>
        CommentsLikesDataSourceImpl(
            sessionService: sl<SessionService>(),
            userAccountService: sl<IUserAccountService>()
        )
    );

    sl.registerLazySingleton<SharesDataSource>(() =>
        SharesDataSourceImpl(
            sessionService: sl<SessionService>(),
            userAccountService: sl<IUserAccountService>()
        )
    );

    // Repositories
    sl.registerLazySingleton<LikesRepository>(() =>
        LikesRepositoryImpl(
            dataSource: sl<LikesDataSource>()
        )
    );

    sl.registerLazySingleton<CommentsRepository>(() =>
        CommentsRepositoryImpl(
            dataSource: sl<CommentsDataSource>()
        )
    );

    sl.registerLazySingleton<CommentsLikesRepository>(() =>
        CommentsLikesRepositoryImpl(
            dataSource: sl<CommentsLikesDataSource>()
        )
    );

    sl.registerLazySingleton<SharesRepository>(() =>
        SharesRepositoryImpl(dataSource: sl<SharesDataSource>()
        )
    );

    // UseCases
    sl.registerLazySingleton<GetLikesStreamUseCase>(() =>
        GetLikesStreamUseCase(repository: sl<LikesRepository>())
    );
    sl.registerLazySingleton<AddCommentUseCase>(() =>
        AddCommentUseCase(repository: sl<CommentsRepository>())
    );
    sl.registerLazySingleton<RemoveCommentUseCase>(() =>
        RemoveCommentUseCase(repository: sl<CommentsRepository>())
    );
    sl.registerLazySingleton<AddCommentLikeUseCase>(() =>
        AddCommentLikeUseCase(repository: sl<CommentsRepository>())
    );
    sl.registerLazySingleton<DeleteCommentLikeUseCase>(() =>
        DeleteCommentLikeUseCase(repository: sl<CommentsRepository>())
    );
    sl.registerLazySingleton<GetCommentsStreamUseCase>(() =>
        GetCommentsStreamUseCase(repository: sl<CommentsRepository>())
    );
    sl.registerLazySingleton<GetCommentLikesStreamUseCase>(() =>
        GetCommentLikesStreamUseCase(
            repository: sl<CommentsLikesRepository>()));
    sl.registerLazySingleton<GetSharesStreamUseCase>(() =>
        GetSharesStreamUseCase(repository: sl<SharesRepository>()
        )
    );

    // Cubits
    sl.registerFactory<CommentsCubit>(() =>
        CommentsCubit(
            addCommentUseCase: sl<AddCommentUseCase>(),
            removeCommentUseCase: sl<RemoveCommentUseCase>(),
            addCommentLikeUseCase: sl<AddCommentLikeUseCase>(),
            deleteCommentLikeUseCase: sl<DeleteCommentLikeUseCase>(),
            getCommentsStreamUseCase: sl<GetCommentsStreamUseCase>()
        )
    );

    sl.registerFactory<LikesCubit>(() =>
        LikesCubit(getLikesStreamUseCase: sl<GetLikesStreamUseCase>())
    );

    sl.registerFactory<SharesCubit>(() =>
        SharesCubit(getSharesStreamUseCase: sl<GetSharesStreamUseCase>())
    );

    sl.registerFactory<CommentsLikesCubit>(() =>
        CommentsLikesCubit(
            getCommentLikesStreamUseCase: sl<GetCommentLikesStreamUseCase>())
    );
  }
}