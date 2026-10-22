import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/di/service _locator.dart';
import '../core/themes/theme_notifier.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../core/navigation/navigation_keys.dart';
import 'package:social_app/core/constants/app_colors.dart';
import '../core/domain/data_sources/local/cache_helper.dart';
import '../features/main/presentation/screens/main_screen.dart';
import '../features/friendship/presentation/cubits/friendship_cubit.dart';
import 'package:social_app/features/main/presentation/cubits/main_cubit.dart';
import '../features/notifications/presentation/cubits/notifications_cubit.dart';
import 'package:social_app/features/public/presentation/cubits/public_cubit.dart';
import 'package:social_app/features/profile/presentation/cubits/my_profile_cubit.dart';
import 'package:social_app/features/user_details/presentation/cubits/my_details_cubit.dart';
import 'package:social_app/features/user_details/presentation/cubits/friends_details_cubit.dart';


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  //colors
  static const _red = AppColors.red;
  static const _grey = AppColors.grey;
  static const _white = AppColors.white;
  static const _black = AppColors.black;
  static const _grey900 = Color(0xFF212121);

  @override
  Widget build(BuildContext context) {
    final lightTheme = ThemeData(
      colorScheme: ColorScheme.light(
        primary: _black,
        onPrimary: _white,
        // نص على العناصر الأساسية (أبيض)
        secondary: _black,
        onSecondary: _white,
        // نص على العناصر الثانوية (أبيض)
        background: _white,
        // لون الخلفية العامة
        onBackground: _black,
        // لون النص على الخلفية العامة (أسود)
        error: _red,
        onError: _white,
        // نص على ألوان الخطأ (أبيض)
        surface: _white,
        onSurface: _black, // لون النص على السطح (أسود)
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all(_black),
          foregroundColor: MaterialStateProperty.all(_white), // لون النص
          textStyle: MaterialStateProperty.all(
            TextStyle(color: _white), // لون النص داخل الأزرار
          ),
        ),
      ),
      indicatorColor: _black,
      tabBarTheme: TabBarThemeData(
        indicatorColor: _black,
        labelColor: _black, // لون نص التبويب النشط
        unselectedLabelColor: _grey,
      ),
    );

    final darkTheme = ThemeData(
      colorScheme: ColorScheme.dark(
        primary: _white,
        // لون العناصر الرئيسية
        onPrimary: _white,
        // لون النص على العناصر الرئيسية
        secondary: Colors.blue,
        // لون العناصر الثانوية
        onSecondary: _white,
        // لون النص على العناصر الثانوية
        surface: _grey900,
        // لون السطح
        background: _grey900,
        // لون الخلفية العامة
        error: _red,
        // لون الخطأ
        onError: _white, // لون النص على الخطأ (أبيض)
      ),
      indicatorColor: _black,
      tabBarTheme: TabBarThemeData(
        indicatorColor: _white,
        labelColor: _white, // لون نص التبويب النشط
        unselectedLabelColor: _grey,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all(_black),
          foregroundColor: MaterialStateProperty.all(_black), // لون النص
        ),
      ),
    );

    return MultiBlocProvider(
        providers: [
          BlocProvider<MainCubit>(create: (context) =>
          sl<MainCubit>()
            ..checkOnAnyFriends()
            ..startListeningToCounters()),
          BlocProvider<MyDetailsCubit>(
              create: (context) =>
              sl<MyDetailsCubit>()
                ..updateMyDetails()
          ),
          BlocProvider<FriendsDetailsCubit>(
              create: (context) =>
              sl<FriendsDetailsCubit>()
                ..updateFriendsDetails()
          ),
          BlocProvider<PublicCubit>(
              create: (context) =>
              sl<PublicCubit>()
                ..getHomePosts()
                ..getHomeStatus()
          ),

          BlocProvider<MyProfileCubit>(
            create: (context) => sl<MyProfileCubit>(),
          ),
          BlocProvider<FriendshipCubit>(
            create: (context) => sl<FriendshipCubit>(),
          ),
          BlocProvider<NotificationsCubit>(
              create: (context) => sl<NotificationsCubit>()
          ),
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
        )
    );
  }
}