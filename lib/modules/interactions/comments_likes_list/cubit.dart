import 'dart:async';
import 'package:flutter/cupertino.dart';
import '../../../models/comment_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_app/models/user_model.dart';
import '../../../shared/constants/user_details.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../shared/componentes/public_components.dart';
import 'package:social_app/shared/cubit_states/cubit_states.dart';


class CommentsLikesCubit extends Cubit<CubitStates> {

  CommentsLikesCubit() : super(InitialState());

  static CommentsLikesCubit get(context) => BlocProvider.of(context);
  StreamSubscription? _likesSubscription;


  Future<void> insertFriendsRequests({
    required final String userId,
  }) async {
    emit(LoadingState());
    try {
      final fireStore = FirebaseFirestore.instance;
      UserModel friendsInfo = UserModel(
          userId: UserDetails.uId,
          dateTime: DateTime.now()
      );
      await fireStore.collection('users').doc(userId)
          .collection(
          'requests').doc(friendsInfo.userId)
          .set(friendsInfo.toMap());

      emit(SuccessState.empty());
    }
    catch (error) {
      emit(ErrorState(error: error.toString()));
    }
  }

  void listenToLikes(CommentModel? comment) {
    _likesSubscription?.cancel();

    if (comment == null) {
      emit(SuccessState<UserModel>.withList(modelsList: []));
      return;
    }

    emit(LoadingState());

    final firebase = FirebaseFirestore.instance;

    firebase.collection('users').doc(UserDetails.uId).collection('friends').get().then((friendsSnapshot) {
      final friendsList = friendsSnapshot.docs.map((doc) => doc.id).toList();

      _likesSubscription = firebase.collection('posts')
          .doc(comment.postId).collection('commentsList').doc(comment.docId)
          .collection('commentsLikes')
          .snapshots()
          .listen((likesSnapshot) async {
        if (likesSnapshot.docs.isEmpty) {
          emit(SuccessState<UserModel>.withList(modelsList: []));
          return;
        }

        final List<UserModel> validUsers = [];
        for (final like in likesSnapshot.docs) {
          try {
            final userId = like.id;
            final accountDoc = await firebase.collection('accounts').doc(userId).get();
            if (!accountDoc.exists) continue;

            final accountData = accountDoc.data() as Map<String, dynamic>;
            final isFriend = friendsList.contains(userId);
            accountData['isFriend'] = isFriend;

            final userAccount = await getUserAccount(userAccount: accountData);
            validUsers.add(UserModel.fromJson(userAccount));
          } catch (e) {
            debugPrint('Error processing like from user ${like.id}: $e');
          }
        }
        emit(SuccessState<UserModel>.withList(modelsList: validUsers));
      }, onError: (e) {
        emit(ErrorState(error: e.toString()));
      });
    });
  }

  @override
  Future<void> close() async {
    await _likesSubscription?.cancel();
    return super.close();
  }
}