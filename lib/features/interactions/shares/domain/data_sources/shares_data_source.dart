import 'package:social_app/core/data/models/my_model.dart';
import '../../../../../core/domain/data_sources/remote/firestore/firestore_service.dart';


abstract class SharesDataSource implements FirestoreService{
  Stream<List<MyModel>> getSharesStream(String postId);
}