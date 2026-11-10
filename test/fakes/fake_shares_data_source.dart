import 'package:social_app/core/data/models/my_model.dart';
import 'package:social_app/core/data/data_sources/remote/firestore/firestore_service_impl.dart';
import 'package:social_app/features/interactions/shares/domain/data_sources/shares_data_source.dart';


class FakeSharesDataSource extends FirestoreServiceImpl implements SharesDataSource {
  Stream<List<MyModel>>? sharesStream;
  int getSharesStreamCallCount = 0;
  String? lastPostId;

  @override
  Stream<List<MyModel>> getSharesStream(String postId) {
    getSharesStreamCallCount++;
    lastPostId = postId;
    return sharesStream!;
  }
}