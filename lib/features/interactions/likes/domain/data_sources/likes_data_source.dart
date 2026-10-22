import 'package:social_app/core/data/models/my_model.dart';
import '../../../../../core/domain/data_sources/remote/firestore/firestore_service.dart';


abstract class LikesDataSource implements FirestoreService{
  Stream<List<MyModel>> getLikesStream(String postId);
}