import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:erin_support_internal/others/save.dart';
import 'package:erin_support_internal/screens/auth/login.dart';
import 'package:erin_support_internal/screens/home.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  // Transparent system bars
  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle(
      statusBarColor: Colors.white,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarDividerColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  // Widget build(BuildContext context) {
  //   return MaterialApp(home: Home());
  // }
  Widget build(BuildContext context) {
    // return MaterialApp(home: Home());
    return MaterialApp(
      title: 'Erin Support',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Lexend',
        pageTransitionsTheme: const PageTransitionsTheme(
          builders: {
            TargetPlatform.android: ZoomPageTransitionsBuilder(),
            TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          },
        ),
      ),
      home: FutureBuilder<bool>(
        future: hasUser(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Login();
          } else if (snapshot.data == true) {
            return Home();
          } else {
            return Login();
          }
        },
      ),
    );
  }

  Future<bool> hasUser() async {
    if (await Save.hasUser()) {
      return true;
    } else {
      return false;
    }
  }
}