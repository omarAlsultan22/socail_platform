import '../../data/models/post_model.dart';
import '../../services/data/session_service.dart';
import '../../data/models/message_result.dart';
import '../../../features/public/data/models/user_details.dart';


abstract interface class PostContext {
  PostModel get postModel;
  UserDetails get userDetails;
  MessageResult get messageResult;
  SessionService get sessionService;
  void Function(PostModel) get onUpsert;
}