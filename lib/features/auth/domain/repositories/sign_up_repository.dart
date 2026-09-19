import 'package:social_app/core/data/models/account_model.dart';


abstract class SignUpRepository {
  Future<void> createUserInfo({
    required UserAccount userModel
  });
}