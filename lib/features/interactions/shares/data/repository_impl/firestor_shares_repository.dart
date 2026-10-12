import '../datasources/shares_remote_datasource.dart';
import '../../domain/repository/shares_repository.dart';
import 'package:social_app/core/data/models/my_model.dart';


class SharesRepositoryImpl implements SharesRepository {
  final SharesRemoteDataSource remoteDataSource;

  SharesRepositoryImpl({required this.remoteDataSource});

  @override
  Stream<List<MyModel>> getSharesStream(String postId) {
    return remoteDataSource.getSharesStream(postId);
  }
}