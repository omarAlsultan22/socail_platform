import 'dart:async';
import 'package:flutter/cupertino.dart';
import '../../../models/post_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_app/models/user_model.dart';
import '../../../shared/constants/user_details.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../shared/componentes/public_components.dart';
import 'package:social_app/shared/cubit_states/cubit_states.dart';


class LikesCubit extends Cubit<CubitStates> {

  LikesCubit() : super(InitialState());

  static LikesCubit get(context) => BlocProvider.of(context);
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

  Future<UserModel> getLikeModel({
    required PostModel postModel,
  })async {
    UserModel userModel;
    try {
      final data = await FirebaseFirestore.instance
          .collection('accounts').doc(UserDetails.uId).get();
      final json = await getAccountMap(userDoc: data);

      json['docId'] = (postModel.likesList!.length + 1).toString();
      userModel = UserModel.fromJson(json);
    } catch (e) {
      rethrow;
    }
    return userModel;
  }

  Future<void> addLike({
    required String postId,
    required String userId
  })async {
    try {
      final docRef = FirebaseFirestore.instance
          .collection('posts')
          .doc(postId);
      if(userId == UserDetails.uId) {
        docRef.update({'isActive': true});
      }
      final action = docRef.collection('likesList').doc(userId);

      UserModel userModel = UserModel(
          userId: userId,
          dateTime: DateTime.now()
      );


      await action.set(userModel.toMap());
    } catch (e) {
      print('Error inserting like: $e');
      rethrow;
    }
  }

  void listenToLikes(String? docId) {
    _likesSubscription?.cancel();

    if (docId == null || docId.isEmpty) {
      emit(SuccessState<UserModel>.withList(modelsList: []));
      return;
    }

    emit(LoadingState());

    final firebase = FirebaseFirestore.instance;

    firebase.collection('users').doc(UserDetails.uId).collection('friends').get().then((friendsSnapshot) {
      final friendsList = friendsSnapshot.docs.map((doc) => doc.id).toList();

      _likesSubscription = firebase.collection('posts')
          .doc(docId)
          .collection('likesList')
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
        validUsers.sort((a, b) => b.dateTime!.compareTo(a.dateTime!));
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

  Future<void> deleteLike({
    required String postId,
    required String userId
  })async {
    try {
      final docRef = FirebaseFirestore.instance
          .collection('posts')
          .doc(postId);
      if(userId == UserDetails.uId) {
        docRef.update({'isActive': false});
      }
      final action = docRef.collection('likesList').doc(userId);

      await action.delete();
    } catch (e) {
      print('Error deleting like: $e');
      rethrow;
    }
  }
}