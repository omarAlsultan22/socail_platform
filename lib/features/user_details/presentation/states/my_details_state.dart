import '../../../public/data/models/user_details.dart';


class MyDetailsState {
  final UserDetails userDetails;

  MyDetailsState({required this.userDetails});

  factory MyDetailsState.initial() =>
      MyDetailsState(userDetails: UserDetails());

  MyDetailsState copyWith({UserDetails? userDetails}) =>
      MyDetailsState(userDetails: userDetails ?? this.userDetails);
}

