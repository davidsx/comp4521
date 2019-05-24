// # COMP 4521       #  LAU CHUN HONG        20349438        chlauap
import 'package:calendar/index.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../main.dart';

class SignUpScreen extends StatefulWidget {
  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  SharedPreferences prefs;

  bool _autovalidate = false;
  String _name;
  String _email;
  // String _mobile;
  String _password;

  bool _error = false;
  String errormsg = ' ';

  bool isLoading = false;
  bool isLoggedIn = false;
  FirebaseUser currentUser;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        // leading: IconButton(
        //   icon: Icon(
        //     Icons.keyboard_arrow_left,
        //     size: 35.0,
        //   ),
        //   color: Colors.black,
        //   onPressed: () {
        //     Navigator.of(context).pushReplacementNamed('/SplashScreen');
        //   },
        // ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Create Account',
                    style: TextStyle(fontSize: 40.0),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Form(
                  key: _formKey, autovalidate: _autovalidate, child: formUI()),
            ),
            // socialDivider(),
            // socialWidget(),
          ],
        ),
      ),
    );
  }

  void _signUp() async {
    prefs = await SharedPreferences.getInstance();

    this.setState(() {
      isLoading = true;
      _error = false;
    });
    try {
      FirebaseUser firebaseUser = await firebaseAuth
          .createUserWithEmailAndPassword(email: _email, password: _password);

      // Update data to server for new user
      Firestore.instance
          .collection('users')
          .document(firebaseUser.uid)
          .setData({
        'id': firebaseUser.uid,
        'username': _name,
        'email': _email,
        // 'phone': firebaseUser.phoneNumber,
        'photoUrl': firebaseUser.photoUrl
      });

      // Write data to local
      currentUser = firebaseUser;
      await prefs.setString('id', currentUser.uid);
      await prefs.setString('username', _name);
      await prefs.setString('email', _email);
      // await prefs.setString('phone', currentUser.phoneNumber);
      await prefs.setString('photoUrl', currentUser.photoUrl);

      Fluttertoast.showToast(msg: "Sign up success");

      this.setState(() {
        isLoading = false;
      });

      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => HomePage(prefs.getString('id'))),
      );
    } catch (e) {
      errormsg = e.toString().split(', ')[1];
      print("$errormsg");
      this.setState(() {
        isLoading = false;
        _error = true;
      });
    }
  }

  formUI() => Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          TextFormField(
            decoration: const InputDecoration(
                hintText: 'Name',
                contentPadding: EdgeInsets.only(top: 40.0, bottom: 20.0)),
            keyboardType: TextInputType.text,
            validator: validateName,
            onSaved: (String val) {
              _name = val;
            },
          ),
          TextFormField(
            decoration: const InputDecoration(
                hintText: 'Email',
                contentPadding: EdgeInsets.only(top: 40.0, bottom: 20.0)),
            keyboardType: TextInputType.emailAddress,
            validator: validateEmail,
            onSaved: (String val) {
              _email = val;
            },
          ),
          TextFormField(
            obscureText: true,
            decoration: const InputDecoration(
                hintText: 'Password',
                contentPadding: EdgeInsets.only(top: 40.0, bottom: 20.0)),
            keyboardType: TextInputType.text,
            validator: validatePassword,
            onSaved: (String val) {
              _password = val;
            },
          ),
          Visibility(
              visible: _error,
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Text(
                  errormsg,
                  style: TextStyle(color: SampleColor.red),
                ),
              )),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 30.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  'Sign Up',
                  style: TextStyle(fontSize: 25.0, fontWeight: FontWeight.w400),
                ),
                CircleAvatar(
                  radius: 40.0,
                  child: IconButton(
                    icon: Icon(Icons.arrow_forward),
                    onPressed: () {
                      _formKey.currentState.save();
                      _signUp();
                    },
                  ),
                )
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 20.0, top: 60.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                InkWell(
                  child: Text('Already have an account?',
                      style: TextStyle(decoration: TextDecoration.underline)),
                  onTap: () {
                    Navigator.of(context).pushReplacementNamed('/SignInScreen');
                  },
                ),
              ],
            ),
          ),
        ],
      );

  socialWidget() => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Container(
            margin: EdgeInsets.all(8.0),
            decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.black)),
            child: CircleAvatar(
              child: Icon(FontAwesomeIcons.facebookF),
              foregroundColor: Colors.black,
              backgroundColor: Colors.transparent,
            ),
          ),
          Container(
            margin: EdgeInsets.all(8.0),
            decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.black)),
            child: CircleAvatar(
              child: Icon(FontAwesomeIcons.google),
              foregroundColor: Colors.black,
              backgroundColor: Colors.transparent,
            ),
          ),
          Container(
            margin: EdgeInsets.all(8.0),
            decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.black)),
            child: CircleAvatar(
              child: Icon(FontAwesomeIcons.twitter),
              foregroundColor: Colors.black,
              backgroundColor: Colors.transparent,
            ),
          ),
        ],
      );

  socialDivider() => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          horizontalLine(),
          Text(
            'Sign in with social media',
            style: TextStyle(color: Colors.black.withOpacity(0.6)),
          ),
          horizontalLine()
        ],
      );

  horizontalLine() => Padding(
        padding: EdgeInsets.symmetric(horizontal: 8.0),
        child: Container(
          height: 1.0,
          width: 50.0,
          color: Colors.black.withOpacity(0.6),
        ),
      );

  String validateName(String value) {
    if (value.length < 7)
      return 'Name must be more than 6 charater';
    else if (value.isEmpty)
      return 'Please input the your name';
    else
      return null;
  }

  String validateEmail(String value) {
    Pattern pattern =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    RegExp regex = new RegExp(pattern);
    if (!regex.hasMatch(value))
      return 'Enter Valid Email';
    else
      return null;
  }

  String validateMobile(String value) {
    if (value.length != 8)
      return 'Mobile Number must be of 10 digit';
    else
      return null;
  }

  String validatePassword(String value) {
    if (value.length < 8)
      return 'Password must be more than 7 character';
    else
      return null;
  }
}
