import '../../domain/repository/likes_repository.dart';
import '../../domain/data_sources/likes_data_source.dart';
import 'package:social_app/core/data/models/my_model.dart';


class LikesRepositoryImpl implements LikesRepository {
  final LikesDataSource _dataSource;

  LikesRepositoryImpl({required LikesDataSource dataSource})
      : _dataSource = dataSource;

  @override
  Stream<List<MyModel>> getLikesStream(String postId) {
    return _dataSource.getLikesStream(postId);
  }
}