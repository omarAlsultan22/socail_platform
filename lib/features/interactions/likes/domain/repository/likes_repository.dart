import 'package:social_app/core/data/models/my_model.dart';


abstract class LikesRepository {
  Stream<List<MyModel>> getLikesStream(String postId);
}