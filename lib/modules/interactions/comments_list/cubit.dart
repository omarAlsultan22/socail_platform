import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_app/models/comment_model.dart';
import 'package:social_app/shared/cubit_states/cubit_states.dart';
import '../../../models/user_model.dart';
import '../../../shared/componentes/constants.dart';
import '../../../shared/componentes/public_components.dart';

class CommentsCubit extends Cubit<CubitStates> {

  CommentsCubit() : super(InitialState());

  static CommentsCubit get(context) => BlocProvider.of(context);
  final List<CommentModel> commentsList = [];
  StreamSubscription? _commentsSubscription;

  void listenToComments(String? docId) {
    _commentsSubscription?.cancel();

    if (docId == null || docId.isEmpty) {
      emit(ListSuccessState<CommentModel>(modelsList: []));
      return;
    }

    emit(LoadingState());

    final firebase = FirebaseFirestore.instance;
    final commentsRef = firebase.collection('posts').doc(docId).collection('commentsList');

    _commentsSubscription = commentsRef.snapshots().listen((snapshot) async {
      if (snapshot.docs.isEmpty) {
        emit(ListSuccessState<CommentModel>(modelsList: []));
        return;
      }
      final List<CommentModel> validUsers = [];
      for (final comment in snapshot.docs) {
        try {
          final commentFields = comment.data();
          final userId = commentFields['userId'];
          final commentId = comment.id;

          final likesSnapshot = await commentsRef
              .doc(commentId)
              .collection('commentsLikes')
              .count()
              .get();

          final likesNumber = likesSnapshot.count;

          final accountFields = await firebase.collection('accounts').doc(userId).get();
          if (!accountFields.exists) continue;

          final userAccount = await getAccountMap(userDoc: accountFields);
          validUsers.add(
            CommentModel.fromJson({
              ...userAccount,
              ...commentFields,
              'likesNumber': likesNumber,
              'docUid': commentId,
            }),
          );
        } catch (e) {
          print("خطأ في جلب تعليق: $e");
        }
      }
      validUsers.sort((a, b) => b.dateTime!.compareTo(a.dateTime!));

      emit(ListSuccessState<CommentModel>(modelsList: validUsers));
    }, onError: (e) {
      emit(ErrorState(error: e.toString()));
    });
  }

  @override
  Future<void> close() async {
    await _commentsSubscription?.cancel();
    return super.close();
  }


  Future<void> addComment({
    required String postId,
    required String comment,
  }) async {
    try {
      final firestore = FirebaseFirestore.instance;
      final accountFields = await firestore.collection('accounts').doc(UserDetails.uId).get();
      final docRef = firestore
          .collection('posts')
          .doc(postId)
          .collection('commentsList')
          .doc();

      final docId = docRef.id;

      if (!accountFields.exists) return;
      final userAccount = await getAccountMap(userDoc: accountFields);
      final actionModel = CommentModel.fromJson({
        ...userAccount,
        'postId': postId,
        'docUid': docId,
        'userAction': comment,
        'timestamp': FieldValue.serverTimestamp(),
      });
      await docRef.set(actionModel.toMap());
    } catch (e) {
      emit(ErrorState(error: e.toString()));
      rethrow;
    }
  }


  Future<void> deleteComment({
    required CommentModel comment,
  }) async {
    try {
      final docRef = FirebaseFirestore.instance
          .collection('posts')
          .doc(comment.postId).collection('commentsList').doc(comment.docId);
      await docRef.delete();
    } catch (e) {
      emit(ErrorState(error: e.toString()));
      rethrow;
    }
  }

  void chickLike({
    required bool isLike,
    required CommentModel comment,
  }) {
    if (isLike) {
      addLike(comment: comment);
    }
    else {
      deleteLike(comment: comment);
    }
  }


  Future<void> addLike({
    required CommentModel comment,
  }) async {
    emit(LoadingState());
    try {
      final postRef = FirebaseFirestore.instance
          .collection('posts')
          .doc(comment.postId).collection('commentsList').doc(comment.docId);
      if(comment.userId == UserDetails.uId) {
        postRef.update({'isActive': true});
      }
      final docRef = postRef.collection(
          'commentsLikes').doc(UserDetails.uId);

      UserModel userModel = UserModel(
          userId: UserDetails.uId,
          dateTime: DateTime.now()
      );
      await docRef.set(userModel.toMap());
      emit(SuccessState());
    } catch (e) {
      emit(ErrorState(error: e.toString()));
      rethrow;
    }
  }

  Future<void> deleteLike({
    required CommentModel comment,
  }) async {
    emit(LoadingState());
    try {
      final postRef = FirebaseFirestore.instance
          .collection('posts')
          .doc(comment.postId).collection('commentsList').doc(comment.docId);
      if(comment.userId == UserDetails.uId) {
        postRef.update({'isActive': false});
      }
      final docRef = postRef.collection(
          'commentsLikes').doc(UserDetails.uId);
      await docRef.delete();
      emit(SuccessState());
    } catch (e) {
      emit(ErrorState(error: e.toString()));
      rethrow;
    }
  }
}