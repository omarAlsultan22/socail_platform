import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:social_app/modules/main_screen/main_screen.dart';
import 'package:social_app/modules/notifications_screen/cubit.dart';
import 'package:social_app/modules/profile_screen/cubit.dart';
import 'package:social_app/shared/componentes/constants.dart';
import 'package:social_app/shared/local/shared_preferences.dart';
import 'package:social_app/shared/remote/firebase_options.dart';
import 'modules/friends_screen/cubit.dart';
import 'modules/home_screen/cubit.dart';
import 'modules/interactions/comments_list/cubit.dart';
import 'modules/main_screen/cubit.dart';
import 'modules/menu_screen/cubit.dart';
import 'modules/notification_service/notification_service.dart';
import 'modules/search_screen/cubit.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
//⭐\\
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await CacheHelper.init();
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    await NotificationService.setupBackgroundIsolate();

    await NotificationService().initialize();

    final RemoteMessage? initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      NotificationService().handleNotification(initialMessage.data);
    }

    await FirebaseMessaging.instance.setAutoInitEnabled(true);

    await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
  } catch (e) {
    print("Firebase initialization error: $e");
  }

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider<MainLayoutCubit>(create: (context) =>
        MainLayoutCubit()
          ..checkOnAnyFriends(uId: UserDetails.uId)
          ..startListeningToCounters()), //
        BlocProvider<HomeCubit>(
            create: (context) =>
            HomeCubit(
                firestore: FirebaseFirestore.instance)
              ..getHomePosts()
              ..getHomeStatus()
              ..getUserAccount()
        ),

        BlocProvider<ProfileCubit>(
          create: (context) => ProfileCubit(),
          key: const ValueKey('myProfile'),
        ),

        BlocProvider<NotificationsCubit>(
            create: (context) => NotificationsCubit()),
        BlocProvider<FriendsCubit>(create: (context) => FriendsCubit()),
        BlocProvider<SearchCubit>(create: (context) => SearchCubit()),
        BlocProvider<AppModelCubit>(create: (context) => AppModelCubit()),
        BlocProvider<CommentsCubit>(create: (context) => CommentsCubit()),
      ],
      child: const MyApp(),
    ),
  );
}


class ThemeNotifier with ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;

  ThemeMode get themeMode => _themeMode;

  ThemeNotifier() {
    _loadTheme();
  }

  void setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    notifyListeners();

    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('theme', mode.toString());
  }

  void _loadTheme() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? theme = prefs.getString('theme');
      if (theme == ThemeMode.dark.toString()) {
        _themeMode = ThemeMode.dark;
      } else if (theme == ThemeMode.light.toString()) {
        _themeMode = ThemeMode.light;
      } else {
        _themeMode = ThemeMode.system;
      }
      notifyListeners();
    } catch (e) {
      print("Error loading theme: $e");
    }
  }
}

ThemeData getLightTheme() {
  return ThemeData(
    colorScheme: ColorScheme.light(
      primary: Colors.black,
      onPrimary: Colors.white, // نص على العناصر الأساسية (أبيض)
      secondary: Colors.black,
      onSecondary: Colors.white, // نص على العناصر الثانوية (أبيض)
      background: Colors.white, // لون الخلفية العامة
      onBackground: Colors.black, // لون النص على الخلفية العامة (أسود)
      error: Colors.red,
      onError: Colors.white, // نص على ألوان الخطأ (أبيض)
      surface: Colors.white,
      onSurface: Colors.black, // لون النص على السطح (أسود)
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all(Colors.black),
        foregroundColor: MaterialStateProperty.all(Colors.white), // لون النص
        textStyle: MaterialStateProperty.all(
          TextStyle(color: Colors.white), // لون النص داخل الأزرار
        ),
      ),
    ),
    indicatorColor: Colors.black,
    tabBarTheme: TabBarThemeData(
      indicatorColor: Colors.black,
      labelColor: Colors.black, // لون نص التبويب النشط
      unselectedLabelColor: Colors.grey,
    ),
  );
}

ThemeData getDarkTheme() {
  return ThemeData(
    colorScheme: ColorScheme.dark(
      primary: Colors.white, // لون العناصر الرئيسية
      onPrimary: Colors.white, // لون النص على العناصر الرئيسية
      secondary: Colors.blue, // لون العناصر الثانوية
      onSecondary: Colors.white, // لون النص على العناصر الثانوية
      surface: Colors.grey.shade900, // لون السطح
      background: Colors.grey.shade900, // لون الخلفية العامة
      error: Colors.red, // لون الخطأ
      onError: Colors.white, // لون النص على الخطأ (أبيض)
    ),
    indicatorColor: Colors.black,
    tabBarTheme: TabBarThemeData(
      indicatorColor: Colors.white,
      labelColor: Colors.white, // لون نص التبويب النشط
      unselectedLabelColor: Colors.grey,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all(Colors.black),
        foregroundColor: MaterialStateProperty.all(Colors.black), // لون النص
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ThemeNotifier(),
      child: Consumer<ThemeNotifier>(
        builder: (context, themeNotifier, child) {
          return MaterialApp(
              navigatorKey: navigatorKey,
              routes: {
                '/friends_screen': (context) => MainLayout(targetScreen: 2),
                '/notifications_screen': (context) => MainLayout(targetScreen: 1),
              },
              theme: getLightTheme(),
              darkTheme: getDarkTheme(),
              themeMode: themeNotifier.themeMode,
              debugShowCheckedModeBanner: false,
              home: MainLayout()
          );
        },
      ),
    );
  }
}
