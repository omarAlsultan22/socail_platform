import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:social_app/features/profile/presentation/cubits/user_profile_cubit.dart';
import '../features/profile/cubit.dart';
import '../core/di/service _locator.dart';
import '../core/themes/theme_notifier.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../core/navigation/navigation_keys.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../features/interactions/comments_list/cubit.dart';
import 'package:social_app/core/services/session_service.dart';
import '../features/main/presentation/screens/main_screen.dart';
import '../features/search/presentation/cubits/search_cubit.dart';
import 'package:social_app/core/data/data_sources/local/cache_helper.dart';
import 'package:social_app/features/main/presentation/cubits/main_cubit.dart';
import '../features/notifications/presentation/cubits/notifications_cubit.dart';
import 'package:social_app/features/public/presentation/cubits/public_cubit.dart';


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final lightTheme = ThemeData(
      colorScheme: ColorScheme.light(
        primary: Colors.black,
        onPrimary: Colors.white,
        // نص على العناصر الأساسية (أبيض)
        secondary: Colors.black,
        onSecondary: Colors.white,
        // نص على العناصر الثانوية (أبيض)
        background: Colors.white,
        // لون الخلفية العامة
        onBackground: Colors.black,
        // لون النص على الخلفية العامة (أسود)
        error: Colors.red,
        onError: Colors.white,
        // نص على ألوان الخطأ (أبيض)
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

    final darkTheme = ThemeData(
      colorScheme: ColorScheme.dark(
        primary: Colors.white,
        // لون العناصر الرئيسية
        onPrimary: Colors.white,
        // لون النص على العناصر الرئيسية
        secondary: Colors.blue,
        // لون العناصر الثانوية
        onSecondary: Colors.white,
        // لون النص على العناصر الثانوية
        surface: Colors.grey.shade900,
        // لون السطح
        background: Colors.grey.shade900,
        // لون الخلفية العامة
        error: Colors.red,
        // لون الخطأ
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

    return MultiBlocProvider(
      providers: [
        BlocProvider<MainCubit>(create: (context) =>
        sl<MainCubit>()
          ..checkOnAnyFriends(uId: sl<SessionService>())
          ..startListeningToCounters()), //
    BlocProvider<CommentsCubit>(create: (context) =>
    CommentsCubit()),/check all providers
    BlocProvider<PublicCubit>(
            create: (context) =>
            sl<PublicCubit>()
              ..getHomePosts()
              ..getHomeStatus()
              ..getUserAccount()
        ),

        BlocProvider<UserProfileCubit>(
          create: (context) => sl<UserProfileCubit>(),
        ),

        BlocProvider<NotificationsCubit>(
            create: (context) => sl<NotificationsCubit>()),
        BlocProvider<FriendsCubit>(create: (context) => FriendsCubit()),
      ],
      child: ChangeNotifierProvider(
      create: (_) => ThemeNotifier(cacheHelper: sl<CacheHelper>()),
      child: Consumer<ThemeNotifier>(
        builder: (context, themeNotifier, child) {
          return MaterialApp(
              navigatorKey: NavigationKeys.navigatorKey,
              routes: {
                '/friends_screen': (context) => MainScreen(targetScreen: 2),
                '/notifications_screen': (context) =>
                    MainScreen(targetScreen: 1),
              },
              theme: lightTheme,
              darkTheme: darkTheme,
              themeMode: themeNotifier.themeMode,
              debugShowCheckedModeBanner: false,
              home: MainScreen()
          );
        },
      ),
    );
  }
}