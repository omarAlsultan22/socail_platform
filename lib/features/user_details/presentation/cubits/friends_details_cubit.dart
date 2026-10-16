import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/data/models/my_model.dart';
import '../../domain/use_cases/user_details_use_case.dart';
import 'package:social_app/features/user_details/presentation/states/friends_details_state.dart';


class FriendsDetailsCubit extends Cubit<FriendsDetailsState> {
  final UserDetailsUseCase _userDetailsUseCase;

  StreamSubscription? _friendsListSubscription;
  final Map<String, StreamSubscription<MyModel>> _friendsSubscriptions = {};

  FriendsDetailsCubit({
    required UserDetailsUseCase userDetailsUseCase})
      :
        _userDetailsUseCase = userDetailsUseCase,
        super(FriendsDetailsState.initial());

  FriendsDetailsCubit get(context) => BlocProvider.of(context);

  Future<void> updateFriendsDetails() async {
    await _friendsListSubscription?.cancel();
    await _cancelFriendsSubscriptions();

    _friendsListSubscription = _userDetailsUseCase
        .executeGetNotificationsStream()
        .listen((streamsMap) {
      streamsMap.forEach((uId, stream) {
        _friendsSubscriptions[uId] = stream.listen(
              (friendModel) {
            emit(state.updateFriend(uId, friendModel));
          },
          onError: (e) => print('Error for $uId: $e'),
        );
      });
    });
  }

  Future<void> _cancelFriendsSubscriptions() async {
    for (final sub in _friendsSubscriptions.values) {
      await sub.cancel();
    }
    _friendsSubscriptions.clear();
  }

  @override
  Future<void> close() async {
    await _friendsListSubscription?.cancel();
    await _cancelFriendsSubscriptions();
    return super.close();
  }
}