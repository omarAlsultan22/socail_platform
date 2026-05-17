import 'dart:async';
import '../../models/post_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../shared/constants/user_details.dart';
import '../../services/online_status_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../shared/componentes/public_components.dart';
import 'package:social_app/shared/cubit_states/cubit_states.dart';


class HomeCubit extends Cubit<CubitStates> {

  bool hasMoreStatus = true;
  bool hasMorePosts = true;
  bool isLoadingPosts = false;

  DocumentSnapshot? lastPostDoc;
  DocumentSnapshot? lastStatusDoc;

  final FirebaseFirestore firestore;
  late List<PostModel> homeDataList = [];
  final List<List<PostModel>> homeStatusList = [];
  List<PostModel> myStatuses = [];
  late StreamSubscription _onlineSubscription;
  bool? isOnline;

  HomeCubit({required this.firestore})
      : super(InitialState());

  static HomeCubit get(context) => BlocProvider.of(context);

  void changeIsLoadingPosts(bool value) {
    isLoadingPosts = value;
    emit(SuccessState.empty());
  }

  void getUserOnlineStatus(OnlineStatusService onlineStatusService,
      String userId) {
    _onlineSubscription =
        onlineStatusService.getUserOnlineStatus(userId).listen((value) {
          isOnline = value;
        });
  }

  void addPost(PostModel postModel) {
    homeDataList.insert(0, postModel);
  }

  void addStatus(PostModel statusModel){
    if(homeStatusList.first.first.userId == UserDetails.uId){
      homeStatusList.first.add(statusModel);
    }
    else {
      myStatuses.add(statusModel);
      homeStatusList.insert(0, myStatuses);
    }
  }


  Future<void> insertAndUpdateStatuses({
    required PostModel statusModel
  }) async {
    emit(LoadingState());
    try {
      var firestore = FirebaseFirestore.instance;
      if(statusModel.userId == null) {
        final userModel = await getUserAccountData();

          statusModel
            ..userId = userModel.userId
            ..userName = userModel.userName
            ..userImage = userModel.userImage;

        addStatus(statusModel);
      final docRef = firestore.collection('status').doc(statusModel.docId) ;
      await docRef.set(statusModel.toMap(), SetOptions(merge: true));
      }
      emit(SuccessState.empty());
    }
    catch (error) {
      emit(ErrorState(error: error.toString()));
    }
  }

  Future<void> insertAndUpdatePosts({
    required PostModel postModel
  }) async {
    emit(LoadingState());
    try {
      if(postModel.userId == null){
        final userModel = await getUserAccountData();
        postModel
          ..userId = userModel.userId
          ..userName = userModel.userName
          ..userImage = userModel.userImage
          ..postType = postModel.postType ?? 'post';
      }
      addPost(postModel);
      emit(SuccessState.empty());
    }
    catch (error) {
      emit(ErrorState(error: error.toString()));
    }
  }

  Future<void> getUserAccount()async {
    final userModel = await getUserModelData(id: UserDetails.uId);
    UserDetails.name = userModel.userName!;
    UserDetails.image = userModel.userImage!;
  }


  Future<void> getHomePosts() async {
    if (!hasMorePosts) return;

    emit(LoadingState());

    try {
      final newPosts = await _fetchPosts();
      homeDataList.addAll(newPosts);

      emit(SuccessState.empty());
    } catch (error) {
      debugPrint('Error loading posts: $error');
      emit(ErrorState(error: error.toString()));
    }
  }

  Future<List<PostModel>> _fetchPosts() async {
    final firebase = FirebaseFirestore.instance;

    if (UserDetails.uId.isEmpty) throw Exception('User ID is empty');

    final friendsSnapshot = await firebase.collection('users')
        .doc(UserDetails.uId)
        .collection('friends')
        .get();

    final friendsUIds = friendsSnapshot.docs.map((doc) => doc.id).toList();
    friendsUIds.add(UserDetails.uId);

    var query = firebase.collection('posts')
        .where('userId', whereIn: friendsUIds)
        .where('postType', isEqualTo: 'post')
        .orderBy('dateTime', descending: true);

    if (lastPostDoc != null) {
      query = query.startAfterDocument(lastPostDoc!);
    }

    final result = await Future.wait([
      query.limit(10).get(),
      firebase.collection('users').doc(UserDetails.uId).collection('deleted_posts').get()
    ]);

    final querySnapshot = result[0] as QuerySnapshot;
    final deletedStatusesSnapshot = result[1] as QuerySnapshot;
    final deletedPosts = deletedStatusesSnapshot.docs.map((doc) => doc.id).toList();

    if (querySnapshot.docs.isEmpty) {
      hasMorePosts = false;
      return [];
    }

    lastPostDoc = querySnapshot.docs.last;

    final List<PostModel> posts = [];
    await Future.wait(querySnapshot.docs.map((doc) async {
      try {
        if (deletedPosts.contains(doc.id)) return;

        final data = doc.data() as Map<String, dynamic>;
        if (data.isEmpty || !data.containsKey('userId')) return;

        final userId = data['userId'];
        final isActive = data['friendId'] != null;

        final userAccountDoc = await firebase.collection('accounts').doc(userId).get();
        if (!userAccountDoc.exists) return;

        final userAccount = await getAccountMap(userDoc: userAccountDoc);

        Map<String, dynamic> friendAccount = {};
        if (isActive) {
          final friendAccountDoc = await firebase.collection('accounts').doc(data['friendId']).get();
          if (friendAccountDoc.exists) {
            friendAccount = await getAccountMap(userDoc: friendAccountDoc);
          }
        }

        final postRef = firebase.collection('posts').doc(doc.id);
        final likesCount = (await postRef.collection('likesList').count().get()).count;
        final commentsCount = (await postRef.collection('commentsList').count().get()).count;

        posts.add(
          PostModel.fromFirestoreToPost({
            ...userAccount,
            ...data,
            ...friendAccount,
            'docId': doc.id,
            'likesNumber': likesCount,
            'commentsNumber': commentsCount,
          }),
        );
      } catch (e) {
        debugPrint('Error processing post ${doc.id}: $e');
      }
    }).toList());
    posts.sort((a, b) => b.dateTime!.compareTo(a.dateTime!));
    return posts;
  }

  Future<void> getHomeStatus() async {
    if (!hasMoreStatus) return;
    emit(LoadingState());
    try {
      final newStatus = await _fetchStatus();
      homeStatusList.addAll(newStatus);
      emit(SuccessState.empty());
    } catch (error, stackTrace) {
      debugPrint('Error in getHomeStatus: $error\n$stackTrace');
      emit(ErrorState(error: error.toString()));
    }
  }

  Future<List<List<PostModel>>> _fetchStatus() async {
    if (UserDetails.uId.isEmpty) {
      throw Exception('User ID is missing');
    }

    final firebase = FirebaseFirestore.instance;
    List<List<PostModel>> statusModelList = [];

    var friendsQuery = firebase.collection('users')
        .doc(UserDetails.uId)
        .collection('friends')
        .limit(10);

    if (lastStatusDoc != null) {
      friendsQuery = friendsQuery.startAfterDocument(lastStatusDoc!);
    }

    final friendsSnapshot = await friendsQuery.get();
    final deletedStatusesSnapshot = await firebase.collection('users')
        .doc(UserDetails.uId)
        .collection('deleted_statuses')
        .get();

    final deletedStatuses = deletedStatusesSnapshot.docs.map((doc) => doc.id).toList();

    if (friendsSnapshot.docs.isEmpty) {
      hasMoreStatus = false;
      return [];
    }

    lastStatusDoc = friendsSnapshot.docs.last;
    final friendsUIds = friendsSnapshot.docs.map((doc) => doc.id).toList();
    friendsUIds.add(UserDetails.uId);

    for (final uId in friendsUIds) {
      try {
        final statusSnapshot = await firebase.collection('status')
            .where('userId', isEqualTo: uId)
            .orderBy(FieldPath.fromString('dateTime'), descending: true)
            .get();

        if (statusSnapshot.docs.isEmpty) continue;

        final accountSnapshot = await firebase.collection('accounts')
            .doc(statusSnapshot.docs.first['userId'])
            .get();

        if (!accountSnapshot.exists) continue;

        final userAccount = await getAccountMap(userDoc: accountSnapshot);
        List<PostModel> userStatuses = [];

        for (final statusDoc in statusSnapshot.docs) {
          if (deletedStatuses.contains(statusDoc.id)) continue;

          final statusData = {
            ...userAccount,
            ...statusDoc.data(),
          };

          userStatuses.add(PostModel.fromFirestoreToStatus(statusData));
        }

        if (userStatuses.isNotEmpty) {
          if (userStatuses.first.userId == UserDetails.uId) {
            myStatuses = userStatuses;
          } else {
            statusModelList.add(userStatuses);
          }
        }
      } catch (e) {
        debugPrint('Error fetching status for user $uId: $e');
        continue;
      }
    }

    if (myStatuses.isNotEmpty) {
      statusModelList.insert(0, myStatuses);
    }
    statusModelList.sort((a, b) => b.first.dateTime!.compareTo(a.first.dateTime!));

    return statusModelList;
  }

  Future<void> deletePost({
    required PostModel postModel
  }) async {
    final firestore = FirebaseFirestore.instance;
    homeDataList.removeWhere((item)=> item.docId == postModel.docId);
    print("Deleting Post ID: ${postModel.docId}");
    homeDataList.forEach((item) => print("Existing ID: ${item.docId}"));
    if (postModel.userId != UserDetails.uId) {
      firestore.collection('users')
          .doc(UserDetails.uId)
          .collection('deleted_posts')
          .doc(postModel.docId)
          .set({});
      emit(SuccessState.empty());
      return;
    }
    firestore.collection('posts').doc(postModel.docId).delete();
    emit(SuccessState.empty());
  }


  Future<void> deleteStatus({
    required PostModel statusModel,
  }) async {
    try {
      for (var innerList in homeStatusList) {
        innerList.removeWhere((item) => item.docId == statusModel.docId);

        if (innerList.isEmpty) {
          homeStatusList.remove(innerList);
        }
      }

      final firebase = FirebaseFirestore.instance;

      if (statusModel.userId != UserDetails.uId) {
        await firebase.collection('users')
            .doc(UserDetails.uId)
            .collection('deleted_statuses')
            .doc(statusModel.docId)
            .set({});
      } else {
        await firebase.collection('status').doc(statusModel.docId).delete();
      }

      emit(SuccessState.empty());

    } catch (error) {
      emit(ErrorState(error: error.toString()));
    }
  }
  @override
  Future <void> close() async {
    _onlineSubscription.cancel();
    super.close();
  }
}




