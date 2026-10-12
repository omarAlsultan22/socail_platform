import 'package:social_app/core/data/models/my_model.dart';


class UserDetails extends MyModel {
  UserDetails({
    super.myName = '',
    super.myImageUrl = ''
  });

  UserDetails copyWith({
    String? myName,
    String? myImageUrl
  }) {
    return UserDetails(
        myName: myName ?? this.myName,
        myImageUrl: myImageUrl ?? this.myImageUrl
    );
  }
}