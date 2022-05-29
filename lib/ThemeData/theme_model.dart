import 'package:alumni/ThemeData/theme_preference.dart';
import 'package:flutter/material.dart';

class ThemeModel extends ChangeNotifier {
  late bool _isDark;
  late ThemePreference _preference;
  bool get isDark => _isDark;

  ThemeModel() {
    _preference = ThemePreference();
    _isDark = false;
    // currentTheme = LightTheme();
    getPreferences();
  }

  set isDark(bool value) {
    _isDark = value;
    _preference.setTheme(value);
    // if (_isDark) {
    //   currentTheme = DarkTheme();
    // } else {
    //   currentTheme = LightTheme();
    // }
    notifyListeners();
  }

  getPreferences() async {
    _isDark = await _preference.getTheme();
    if (_isDark) {
      //   currentTheme = DarkTheme();
      // } else {
      //   currentTheme = LightTheme();
      // }
      notifyListeners();
    }
  }

// abstract class ColorThemes {
//   // abstract Color appBarColor;
//   // abstract Color mainBorderColor;
//   // abstract Color mainPageColor;
//   // abstract Color bottomNavBarColor;
//   // abstract Color bottomNavBarSelectedItemColor;
//   // abstract Color bottomNavBarUnselectedItemColor;
//   // abstract Color floatingActionButtonColor;
//   // abstract Color drawerColor;
//   // abstract Color titleTextColor;
//   // abstract Color subTitleColor;
// //   const appBarColor = 0xff191919;
// // const tabBarColor = 0xff191919;
// // const backgroundColor = 0xff131313;
// // const drawerColor = 0xff171717;
// // const noticeColor = 0xff7a2c1e;
// // const postCardColor = 0xaf182021;
// // const eventCardColor = 0xaf302020;
// // const floatingButtonColor = 0xff06a700;
// // const postPageBackground = 0xff161718;
// // const eventPageBackground = 0xff251919;
//   abstract Color appBarColor,
//       appBarBorderColor,
//       appBarIconColor,
//       mainScaffoldColor,
//       floatingActionButtonColor,
//       oppositeColor;
//   // tabBarColor,
//   // mainBackgroundColor,
//   // drawerColor,
//   // noticeColor,
//   // postCardColor,
//   // eventCardColor,
//   // postPageBackground,
//   // eventPageBackground;
// }

// class DarkTheme implements ColorThemes {
//   @override
//   Color appBarColor = const Color(0xff212121);
//   @override
//   Color appBarBorderColor = Colors.grey.shade800;
//   @override
//   Color appBarIconColor = const Color(0xffefefff);
//   @override
//   Color mainScaffoldColor = const Color(0xff292929);
//   @override
//   Color floatingActionButtonColor = Color(0xffD9D7F1);
//   @override
//   Color oppositeColor = Colors.white;
// }

// class LightTheme implements ColorThemes {
//   @override
//   Color appBarColor = const Color(0xffF9F7F7);
//   @override
//   Color appBarBorderColor = const Color(0xff112D4E);
//   @override
//   Color appBarIconColor = Colors.grey.shade800;
//   @override
//   Color mainScaffoldColor = Colors.teal.shade100;
//   @override
//   Color floatingActionButtonColor = const Color(0xffdd1c1a);
//   @override
//   Color oppositeColor = Colors.black;
// }
}
