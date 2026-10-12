import 'package:social_app/core/data/models/my_model.dart';


abstract class SharesRepository {
  Stream<List<MyModel>> getSharesStream(String postId);
}