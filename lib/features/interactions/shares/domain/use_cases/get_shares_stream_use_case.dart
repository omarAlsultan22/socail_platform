import '../repository/shares_repository.dart';
import 'package:social_app/core/data/models/my_model.dart';


class GetSharesStreamUseCase {
  final SharesRepository _repository;

  GetSharesStreamUseCase({required SharesRepository repository})
      : _repository = repository;

  Stream<List<MyModel>> call(String postId) {
    return _repository.getSharesStream(postId);
  }
}