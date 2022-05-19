import 'package:alumni/ThemeData/theme_model.dart';
import 'package:alumni/views/login_page.dart';
import 'package:alumni/views/main_page.dart';
import 'package:alumni/views/register_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

void main() {
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
  ));
  WidgetsFlutterBinding.ensureInitialized();
  runApp(ChangeNotifierProvider(
    create: (_) => ThemeModel(),
    child: Consumer<ThemeModel>(
        builder: (context, ThemeModel themeNotifier, child) {
      return MaterialApp(
          routes: {
            "/register": (context) => const RegisterView(),
            "/login": ((context) => const LoginView()),
            "/home": (context) => const MainPage(),
            "/events": ((context) => const MainPage(
                  startingIndex: 1,
                )),
            "/people": (context) => const MainPage(
                  startingIndex: 2,
                ),
            "/forum": (context) => const MainPage(
                  startingIndex: 3,
                ),
          },
          debugShowCheckedModeBanner: false,
          theme: themeNotifier.isDark
              ? ThemeData.dark().copyWith(
                  canvasColor: const Color(0xff181818),
                  brightness: Brightness.dark,
                  inputDecorationTheme: InputDecorationTheme(
                      errorStyle: const TextStyle(fontWeight: FontWeight.bold),
                      enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(4),
                          borderSide: const BorderSide(
                              color: Colors.white70, width: 1))),
                  cardColor: const Color(0xff222222),
                  floatingActionButtonTheme:
                      const FloatingActionButtonThemeData(
                          backgroundColor: Color.fromARGB(255, 185, 180, 243)),
                  scaffoldBackgroundColor: const Color(0xff151515),
                  appBarTheme: AppBarTheme(
                      shadowColor: Colors.grey.shade400,
                      backgroundColor: const Color(0xff292929),
                      foregroundColor: const Color(0xffefefff)),
                )
              : ThemeData.light().copyWith(
                  canvasColor: const Color.fromARGB(255, 185, 231, 227),
                  inputDecorationTheme: InputDecorationTheme(
                      errorStyle: const TextStyle(fontWeight: FontWeight.bold),
                      enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(4),
                          borderSide: BorderSide(
                              color: Colors.grey.shade700, width: 1))),
                  brightness: Brightness.light,
                  cardColor: Colors.teal.shade50,
                  scaffoldBackgroundColor: Colors.teal.shade200,
                  floatingActionButtonTheme:
                      const FloatingActionButtonThemeData(
                          backgroundColor: Color(0xffdd1c1a)),
                  appBarTheme: AppBarTheme(
                      shadowColor: const Color(0xff112D4E),
                      backgroundColor: const Color.fromARGB(255, 255, 239, 239),
                      foregroundColor: Colors.grey.shade900),
                ),
          home: const MainPage());
    }),
  ));
}
