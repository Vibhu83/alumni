import 'package:alumni/views/login_page.dart';
import 'package:alumni/views/main_page.dart';
import 'package:alumni/views/register_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark));
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MaterialApp(
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
      theme: ThemeData.dark(),
      home: const MainPage()));
}
