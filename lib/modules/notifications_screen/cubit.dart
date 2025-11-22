import 'dart:async';
import '../main_screen/cubit.dart';
import '../../models/post_model.dart';
import '../../models/user_model.dart';
import 'package:flutter/cupertino.dart';
import '../../models/notification_model.dart';
import '../../shared/constants/state_keys.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../shared/constants/user_details.dart';
import '../../shared/cubit_states/cubit_states.dart';
import 'package:social_app/models/comment_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../shared/componentes/public_components.dart';
import 'package:social_app/helpers/notification_data_converter.dart';


class NotificationsCubit extends Cubit<CubitStates> {
  NotificationsCubit() : super(InitialState());

  static NotificationsCubit get(context) => BlocProvider.of(context);

  PostModel? postModel;
  List<CommentModel> commentsList = [];
  List<NotificationsModel> notificationsList = [];
  StreamSubscription? _notificationsSubscription;

  Future<void> insertNotificationsRequests({
    required final String userUid,
    required final String userImage,
    required final String userName,
    required final String userAction
  }) async {
    emit(LoadingState());
    UserModel notificationsData = UserModel(
        userId: userUid,
        userImage: userImage,
        userName: userName);
    try {
      await FirebaseFirestore.instance.collection(
          'notifications').doc(notificationsData.userId)
          .set(notificationsData.toMap());
      emit(SuccessState.empty());
    }
    catch (error) {
      emit(ErrorState(error: error.toString()));
    }
  }

  void getNotificationsRequests({required String userId}) {
    emit(LoadingState(stateKey: StatesKeys.getNotificationsRequests));
    try {
      _notificationsSubscription?.cancel();
      _notificationsSubscription =
          getNotificationsStream(userId: userId).listen(
                (notifications) {
              notificationsList = notifications;
              emit(SuccessState.empty(stateKey: StatesKeys.getNotificationsRequests));
            },
            onError: (error) {
              emit(ErrorState(error: error.toString()));
            },
          );
    } catch (error) {
      emit(ErrorState(error: error.toString(), stateKey: StatesKeys.getNotificationsRequests));
    }
  }


  Stream<List<NotificationsModel>> getNotificationsStream({
    required String userId,
  }) {
    final firestore = FirebaseFirestore.instance;

    return firestore
        .collection('notifications')
        .where('userId', isEqualTo: UserDetails.uId)
        .orderBy('dateTime', descending: true)
        .snapshots()
        .asyncMap((notificationsSnapshot) async {
      final notifications = notificationsSnapshot.docs;
      final List<NotificationsModel> result = [];

      await Future.wait(notifications.map((notificationDoc) async {
        try {
          final userId = notificationDoc['friendId'];
          final userAccount = await firestore
              .collection('accounts')
              .doc(userId)
              .get();

          final notificationData = await NotificationsDataConverter.fromDocumentSnapshot(
              userAccount, notificationDoc);
          result.add(notificationData.notificationsModel);
        } catch (error) {
          rethrow;
        }
      }));

      return result;
    });
  }


  Future<void> getPostData({
    required String userId,
    required String postId,
  }) async {
    emit(LoadingState(stateKey: StatesKeys.getPostData));
    try {
      final firestore = FirebaseFirestore.instance;
      final data = firestore.collection('posts').doc(postId);

      final results = await Future.wait([
        data.get(),
        firestore.collection('accounts').doc(userId).get(),
        data.collection('commentsList').get(),
      ]);

      final postDoc = results[0] as DocumentSnapshot;
      final userDoc = results[1] as DocumentSnapshot;
      final commentsDocs = results[2] as QuerySnapshot;

      if (!postDoc.exists || !userDoc.exists) {
        emit(ErrorState(error: 'Post or user not found', stateKey: StatesKeys.getPostData));
        return;
      }

      final userAccount = await getAccountMap(userDoc: userDoc);

      final likesCount = await data.collection('likesList').count().get();
      final commentsCount = commentsDocs.size;

      final comments = await Future.wait(
        commentsDocs.docs.map((doc) async {
          final commentData = doc.data() as Map<String, dynamic>;
          final commentUserDoc = await firestore
              .collection('accounts')
              .doc(commentData['userId'])
              .get();

          if (!commentUserDoc.exists) return null;

          final userAccount = await getAccountMap(userDoc: commentUserDoc);

          final likesCount = await data
              .collection('commentsList')
              .doc(doc.id)
              .collection('likesList')
              .count()
              .get();

          return CommentModel.fromJson({
            ...userAccount,
            ...commentData,
            'likesNumber': likesCount.count,
          });
        }),
      );

      commentsList = comments.whereType<CommentModel>().toList();
      postModel = PostModel.fromFirestoreToPost({
        ...userAccount,
        ...postDoc.data() as Map<String, dynamic>,
        'likesNumber': likesCount.count,
        'commentsNumber': commentsCount
      });

      emit(SuccessState.empty(stateKey: StatesKeys.getPostData));
    } catch (e) {
      emit(ErrorState(error: 'Failed to load post: ${e.toString()}', stateKey: StatesKeys.getPostData));
    }
  }


  void updateNotificationsCounter({
    required String docId,
    required BuildContext context
  }) {
    FirebaseFirestore.instance.collection('notifications').doc(docId).update(
      {'isRead': true},
    );
    MainLayoutCubit.get(context).deleteNotification();
    emit(SuccessState.empty(stateKey: StatesKeys.updateNotificationsCounter));
  }
}


