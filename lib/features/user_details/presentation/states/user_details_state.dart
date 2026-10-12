import 'package:social_app/features/public/data/models/user_details.dart';


class UserDetailsState {
  final UserDetails userDetails;

  UserDetailsState({required this.userDetails});

  factory UserDetailsState.initial(){
    return UserDetailsState(userDetails: UserDetails());
  }

  UserDetails updateUserDetails({
    String? myName,
    String? myImageUrl
  }) {
    return userDetails.copyWith(
        myName: myName,
        myImageUrl: myImageUrl
    );
  }
}