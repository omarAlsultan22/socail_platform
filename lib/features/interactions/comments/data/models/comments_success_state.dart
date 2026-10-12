import '../../../../../core/data/models/comment_model.dart';
import '../../../../../core/data/models/message_result.dart';
import 'package:social_app/core/presentation/states/base/main_loaded_state.dart';


class CommentsSuccessState extends LoadedState{
  final MessageResult messageResult;
  final List<CommentModel> commentsList;

  CommentsSuccessState({
    required this.commentsList,
    required this.messageResult
  });
}