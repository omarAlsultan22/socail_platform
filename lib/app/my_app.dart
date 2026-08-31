import '../features/main/cubit.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../features/profile/cubit.dart';
import '../core/themes/screen_theme.dart';
import '../core/constants/user_details.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../core/navigation/navigation_keys.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../features/interactions/comments_list/cubit.dart';
import '../features/menu/presentation/cubits/menu_cubit.dart';
import '../features/main/presentation/screens/main_screen.dart';
import '../features/search/presentation/cubits/search_cubit.dart';
import 'package:social_app/core/data/data_sources/local/cache_helper.dart';
import '../features/notifications/presentation/cubits/notifications_cubit.dart';


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final cacheHelper = CacheHelper();
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
            create: (context) => NotificationsCubit(useCases: null)),
        BlocProvider<FriendsCubit>(create: (context) => FriendsCubit()),
        BlocProvider<SearchCubit>(
            create: (context) => SearchCubit(useCase: null)),
        BlocProvider<AppModelCubit>(
            create: (context) => AppModelCubit(useCases: null)),
        BlocProvider<CommentsCubit>(create: (context) => CommentsCubit()),
      ],
      child: ChangeNotifierProvider(
      create: (_) => ThemeNotifier(cacheHelper: cacheHelper),
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