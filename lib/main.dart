 // # COMP 4521       #  LAU CHUN HONG        20349438        chlauap
import 'package:calendar/screen/signin_screen.dart';
import 'package:calendar/screen/signup_screen.dart';
import 'package:calendar/screen/splash_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

void main() => runApp(MyApp());

final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
final GoogleSignIn googleSignIn = GoogleSignIn();

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
          primaryColor: SampleColor.riverBlue,
          primaryColorDark: SampleColor.riverBlueDark,
          floatingActionButtonTheme: FloatingActionButtonThemeData(
            backgroundColor: Colors.orange,
            foregroundColor: SampleColor.white,
          ),
          appBarTheme:
              AppBarTheme(color: SampleColor.riverBlue, elevation: 0.0),
          buttonColor: Colors.orange,
          scaffoldBackgroundColor: SampleColor.riverBlue,
          primaryTextTheme: TextTheme(
            title: TextStyle(color: Colors.black54),
          ),
          fontFamily: 'Raleway',
          primaryIconTheme: IconThemeData(color: SampleColor.riverBlue),
          iconTheme: IconThemeData(color: Colors.orange),
          buttonTheme: ButtonThemeData(
            minWidth: 60.0,
            height: 80.0,
            shape: StadiumBorder(),
            buttonColor: Colors.orange,
            splashColor: Colors.transparent,
          ),
          cardTheme: CardTheme(
              elevation: 12.0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0))),
          canvasColor: Colors.transparent),
      home: SplashScreen(),
      routes: <String, WidgetBuilder>{
        '/SplashScreen': (BuildContext context) => new SplashScreen(),
        '/SignInScreen': (BuildContext context) => new SignInScreen(),
        '/SignUpScreen': (BuildContext context) => new SignUpScreen(),
      },
    );
  }
}

class SampleColor {
  static Color white = Colors.white;
  static Color black = Colors.black;
  static Color grey = Colors.grey;
  // static Color riverBlue = Color(0xff86D8C9);
  static Color riverBlue = Colors.greenAccent.shade100;
  static Color riverBlueDark = Color(0xff55a698);
  static Color lightOrange = Color(0xffFEB527);
  static Color deepOrange = Color(0xffFF9650);
  static Color lightBlue = Color(0xff48C3F3);
  static Color deepBlue = Color(0xff1452FF);
  static Color deepPurple = Color(0xff855FC1);
  static Color lightPurple = Color(0xff5D56F7);
  static Color red = Color(0xfff44336);
  static Color coralRed = Color(0xffEB4985);
  static Color pink = Color(0xffff80ab);
  static Color lightGreen = Color(0xffb2ff59);
  static Color deepGreen = Color(0xff689f38);
}

//helper function

bool isSameDate(date1, date2) {
  return date1.year == date2.year &&
      date1.month == date2.month &&
      date1.day == date2.day;
}

String dateParser(DateTime d) =>
    weeklistCap[d.weekday - 1] +
    ', ' +
    d.day.toString() +
    ' ' +
    monthlist3[d.month - 1] +
    ' ' +
    d.year.toString();
String dateParser2(DateTime d) =>
    weeklistCap[d.weekday - 1] +
    ', ' +
    d.day.toString() +
    ' ' +
    monthlist3[d.month - 1];
String dateParser3(DateTime d) =>
    d.day.toString() + '-' + d.month.toString() + '-' + d.year.toString();

String timeParser(TimeOfDay t) =>
    (t.hour < 12
            ? (t.hour == 0 ? 12 : t.hour)
            : (t.hour == 12 ? 12 : t.hour - 12))
        .toString() +
    ':' +
    (t.minute < 10 ? '0' + t.minute.toString() : t.minute.toString()) +
    ' ' +
    (t.hour > 11 ? 'PM' : 'AM');

getPageIndex(DateTime day) {
  return yearlist.indexOf(day.year) * 12 + (day.month - 1);
}

// date time list

List<String> monthlist = [
  'January',
  'February',
  'March',
  'April',
  'May',
  'June',
  'July',
  'August',
  'September',
  'October',
  'November',
  'December'
];

List<String> monthlist3 =
    List<String>.generate(12, (i) => monthlist[i].substring(0, 3));

List<String> weeklist = ['mon', 'tue', 'wed', 'thu', 'fri', 'sat', 'sun'];
List<String> weeklistCap = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

List<int> yearlist = [
  2015,
  2016,
  2017,
  2018,
  2019,
  2020,
  2021,
  2022,
  2023,
  2024,
  2025
];

