import 'package:social_app/core/data/models/my_model.dart';
import 'package:social_app/core/presentation/states/base/main_loaded_state.dart';


class CommentsLikesSuccessState extends LoadedState{
  final List<MyModel> commentLikesList;

  CommentsLikesSuccessState({
    required this.commentLikesList,
  });
}