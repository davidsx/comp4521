// # COMP 4521       #  LAU CHUN HONG        20349438        chlauap
import 'dart:async';

import 'package:calendar/index.dart';
import 'package:calendar/main.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool isLoading = false, isLoggedIn = false;
  SharedPreferences prefs;
  @override
  void initState() {
    super.initState();
    checkLogin();
    // startTime();
  }

  checkLogin() async {
    this.setState(() {
      isLoading = true;
    });

    prefs = await SharedPreferences.getInstance();

    bool isLoggedIn =
        await googleSignIn.isSignedIn() || prefs.getString('id') != null;

    if (isLoggedIn) {
      // Write data to local
      new Timer(
          Duration(seconds: 2),
          () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => HomePage(prefs.getString('id')))));
    } else {
      this.setState(() {
        isLoading = false;
      });
    }
  }

  void toSignInScreen() {
    Navigator.of(context).pushReplacementNamed('/SignInScreen');
  }

  void toSignUpScreen() {
    Navigator.of(context).pushReplacementNamed('/SignUpScreen');
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? Scaffold(
            backgroundColor: Colors.white,
            // body: Center(child: FlutterLogo(size: 100.0)),
          )
        : Scaffold(
            backgroundColor: Colors.white,
            body: Padding(
              padding: const EdgeInsets.all(30.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  FlutterLogo(
                    size: 100.0,
                  ),
                  SizedBox.fromSize(
                    size: Size.fromHeight(20.0),
                  ),
                  Container(
                    child: Text(
                      "Let's get started",
                      style: TextStyle(
                          fontSize: 24.0, fontWeight: FontWeight.bold),
                    ),
                  ),
                  SizedBox.fromSize(
                    size: Size.fromHeight(20.0),
                  ),
                  Container(
                    child: Text(
                      "Calendar help you manage your time! \n\n" +
                          "You can share your event with \n your friends, family, and colleague.",
                      textAlign: TextAlign.center,
                      style: TextStyle(),
                    ),
                  ),
                  SizedBox.fromSize(
                    size: Size.fromHeight(80.0),
                  ),
                  Container(
                      width: double.maxFinite,
                      decoration: BoxDecoration(
                          // border:
                          //     Border.all(color: Theme.of(context).dividerColor),
                          borderRadius: BorderRadius.circular(20.0),
                          color: Theme.of(context).primaryColor),
                      child: FlatButton(
                          child: Text(
                            'Login',
                            style: TextStyle(
                                color: Colors.black, letterSpacing: 3.0),
                          ),
                          onPressed: toSignInScreen)),
                  SizedBox.fromSize(
                    size: Size.fromHeight(20.0),
                  ),
                  Container(
                      width: double.maxFinite,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20.0),
                          color: Colors.orange),
                      child: FlatButton(
                          child: Text(
                            'Create New Account',
                            style: TextStyle(letterSpacing: 3.0),
                          ),
                          onPressed: toSignUpScreen))
                ],
              ),
            ),
          );
  }
}
