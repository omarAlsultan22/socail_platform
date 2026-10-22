import '../../domain/repository/shares_repository.dart';
import '../../domain/data_sources/shares_data_source.dart';
import 'package:social_app/core/data/models/my_model.dart';


class SharesRepositoryImpl implements SharesRepository {
  final SharesDataSource _dataSource;

  SharesRepositoryImpl({required SharesDataSource dataSource}) : _dataSource = dataSource;

  @override
  Stream<List<MyModel>> getSharesStream(String postId) {
    return _dataSource.getSharesStream(postId);
  }
}