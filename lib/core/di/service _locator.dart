import 'core/di_core.dart';
import 'domains/di_auth.dart';
import 'domains/di_search.dart';
import 'domains/di_public.dart';
import 'package:get_it/get_it.dart';
import 'domains/di_setup_friends.dart';
import 'package:social_app/core/di/domains/di_main.dart';
import 'package:social_app/core/di/domains/di_profile.dart';
import 'package:social_app/core/di/domains/di_user_info.dart';
import 'package:social_app/core/di/domains/di_user_account.dart';
import 'package:social_app/core/di/domains/di_notifications.dart';
import 'package:social_app/core/di/domains/di_friends_interactions.dart';


final sl = GetIt.instance;

void setupServiceLocator() {
  // ============ Core ============
  CoreDependencies.register();

  // ============ Domains ============
  AuthDependencies.register();
  MainDependencies.register();
  PublicDependencies.register();
  SearchDependencies.register();
  ProfileDependencies.register();
  UserInfoDependencies.register();
  UserAccountDependencies.register();
  SetupFriendsDependencies.register();
  NotificationsDependencies.register();
  FriendsInteractionsDependencies.register();
}