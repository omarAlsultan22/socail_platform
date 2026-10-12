import '../datasources/likes_remote_datasource.dart';
import '../../domain/repository/likes_repository.dart';
import 'package:social_app/core/data/models/my_model.dart';


class LikesRepositoryImpl implements LikesRepository {
  final LikesRemoteDataSource remoteDataSource;

  LikesRepositoryImpl({required this.remoteDataSource});

  @override
  Stream<List<MyModel>> getLikesStream(String postId) {
    return remoteDataSource.getLikesStream(postId);
  }
}