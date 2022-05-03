import 'package:alumni/views/login_page.dart';
import 'package:alumni/views/main_page.dart';
import 'package:alumni/views/register_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light));
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MaterialApp(
      routes: {
        "/register": (context) => const RegisterView(),
        "/login": ((context) => const LoginView()),
        "/Home": (context) => const MainPage()
      },
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: const MainPage()));
}
