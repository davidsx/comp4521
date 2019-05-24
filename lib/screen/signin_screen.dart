// # COMP 4521       #  LAU CHUN HONG        20349438        chlauap
import 'package:calendar/index.dart';
import 'package:calendar/main.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluttertoast/fluttertoast.dart';

class SignInScreen extends StatefulWidget {
  @override
  _SignInScreenState createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  SharedPreferences prefs;

  bool _autovalidate = false;
  // String _name;
  String _email;
  // String _mobile;
  String _password;
  // bool _isLoading = false;

  bool _error = false;
  String errormsg = 'error';

  bool isLoading = false;
  bool isLoggedIn = false;
  FirebaseUser currentUser;

  @override
  void initState() {
    super.initState();
  }

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
            Flexible(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Welcome Back',
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
          ],
        ),
      ),
    );
  }

  void _signInWithEmail() async {
    prefs = await SharedPreferences.getInstance();

    this.setState(() {
      isLoading = true;
      _error = false;
    });

    if (_email == null)
      errormsg = "Please filled in your email address";
    else if (_password == null)
      errormsg = "Please filled in your password";
    else
      try {
        FirebaseUser firebaseUser = await firebaseAuth
            .signInWithEmailAndPassword(email: _email, password: _password);

        if (firebaseUser != null) {
          // Check is already sign up
          final QuerySnapshot result = await Firestore.instance
              .collection('users')
              .where('id', isEqualTo: firebaseUser.uid)
              .getDocuments();
          final List<DocumentSnapshot> documents = result.documents;
          if (documents.length == 0) {
            Fluttertoast.showToast(msg: "User not exist");
            this.setState(() {
              isLoading = false;
            });
          } else {
            // Write data to local
            await prefs.setString('id', documents[0]['id']);
            await prefs.setString('username', documents[0]['username'] ?? null);
            await prefs.setString('email', documents[0]['email'] ?? null);
            await prefs.setString('phone', documents[0]['phoneNumber'] ?? null);
            await prefs.setString('photoUrl', documents[0]['photoUrl'] ?? null);

            Fluttertoast.showToast(
              msg: "Sign in success",
              backgroundColor: Theme.of(context).primaryColor,
              textColor: Colors.black,
              timeInSecForIos: 2,
              toastLength: Toast.LENGTH_LONG,
            );

            this.setState(() {
              isLoading = false;
            });

            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => HomePage(prefs.getString('id'))),
            );
          }
        }
      } catch (e) {
        errormsg = e.toString().split(', ')[1];
        print("$errormsg");
        this.setState(() {
          isLoading = false;
          _error = true;
        });
      }
  }

  // sign in with google.
  void _signInWithGoogle() async {
    print("google login");

    prefs = await SharedPreferences.getInstance();

    this.setState(() {
      isLoading = true;
    });

    GoogleSignInAccount googleUser = await googleSignIn.signIn();
    GoogleSignInAuthentication googleAuth = await googleUser.authentication;
    final AuthCredential credential = GoogleAuthProvider.getCredential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    FirebaseUser firebaseUser =
        await firebaseAuth.signInWithCredential(credential);

    if (firebaseUser != null) {
      // Check is already sign up
      final QuerySnapshot result = await Firestore.instance
          .collection('users')
          .where('id', isEqualTo: firebaseUser.uid)
          .getDocuments();
      final List<DocumentSnapshot> documents = result.documents;
      print(documents.length);
      if (documents.length == 0) {
        // Update data to server if new user
        Firestore.instance
            .collection('users')
            .document(firebaseUser.uid)
            .setData({
          'id': firebaseUser.uid,
          'username': firebaseUser.displayName,
          'email': firebaseUser.email,
          'phone': firebaseUser.phoneNumber,
          'photoUrl': firebaseUser.photoUrl
        });

        // Write data to local
        currentUser = firebaseUser;
        await prefs.setString('id', currentUser.uid);
        await prefs.setString('username', currentUser.displayName);
        await prefs.setString('email', currentUser.email);
        await prefs.setString('phone', currentUser.phoneNumber);
        await prefs.setString('photoUrl', currentUser.photoUrl);
      } else {
        print(firebaseUser.photoUrl);
        // Update data of users
        Firestore.instance
            .collection('users')
            .document(firebaseUser.uid)
            .updateData({
          'id': firebaseUser.uid,
          'username': firebaseUser.displayName,
          'email': firebaseUser.email,
          'phone': firebaseUser.phoneNumber,
          'photoUrl': firebaseUser.photoUrl
        });

        // Write data to local
        await prefs.setString('id', documents[0]['id']);
        await prefs.setString('username', documents[0]['username'] ?? null);
        await prefs.setString('email', documents[0]['email'] ?? null);
        await prefs.setString('phone', documents[0]['phoneNumber'] ?? null);
        await prefs.setString('photoUrl', documents[0]['photoUrl'] ?? null);
      }

      Fluttertoast.showToast(
        msg: "Sign in success",
        backgroundColor: Theme.of(context).primaryColor,
        textColor: Colors.black,
        timeInSecForIos: 2,
        toastLength: Toast.LENGTH_LONG,
      );

      this.setState(() {
        isLoading = false;
      });

      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => HomePage(prefs.getString('id'))),
      );
    } else {
      Fluttertoast.showToast(msg: "User not exist");
      this.setState(() {
        isLoading = false;
      });
    }
  }

  formUI() => Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          TextFormField(
            decoration: const InputDecoration(
                hintText: 'Email',
                contentPadding: EdgeInsets.only(top: 40.0, bottom: 20.0)),
            keyboardType: TextInputType.text,
            validator: validateName,
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
                  'Sign in',
                  style: TextStyle(fontSize: 25.0, fontWeight: FontWeight.w400),
                ),
                CircleAvatar(
                  radius: 40.0,
                  child: IconButton(
                    icon: isLoading
                        ? CircularProgressIndicator()
                        : Icon(Icons.arrow_forward),
                    onPressed: () {
                      _formKey.currentState.save();
                      _signInWithEmail();
                    },
                  ),
                )
              ],
            ),
          ),
          socialDivider(),
          // SizedBox.fromSize(size: Size.fromHeight(20.0)),
          socialWidget(),
          Padding(
            padding: const EdgeInsets.only(bottom: 20.0, top: 50.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                InkWell(
                  child: Text('Sign up',
                      style: TextStyle(decoration: TextDecoration.underline)),
                  onTap: () {
                    Navigator.of(context).pushReplacementNamed('/SignUpScreen');
                  },
                ),
                InkWell(
                  child: Text('Forget Passwords',
                      style: TextStyle(decoration: TextDecoration.underline)),
                  onTap: () {},
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
          // Container(
          //   margin: EdgeInsets.all(8.0),
          //   decoration: BoxDecoration(
          //       shape: BoxShape.circle,
          //       border: Border.all(color: Colors.black)),
          //   child: CircleAvatar(
          //     child: Icon(FontAwesomeIcons.facebookF),
          //     foregroundColor: Colors.black,
          //     backgroundColor: Colors.transparent,
          //   ),
          // ),
          Container(
            margin: EdgeInsets.all(8.0),
            decoration: BoxDecoration(
                color: Colors.transparent,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.black)),
            child: CircleAvatar(
              child: IconButton(
                // disabledColor: ,
                icon: Icon(FontAwesomeIcons.google),
                onPressed: _signInWithGoogle,
              ),
              foregroundColor: Colors.black,
              backgroundColor: Colors.transparent,
            ),
          ),
          // Container(
          //   margin: EdgeInsets.all(8.0),
          //   decoration: BoxDecoration(
          //       shape: BoxShape.circle,
          //       border: Border.all(color: Colors.black)),
          //   child: CircleAvatar(
          //     child: Icon(FontAwesomeIcons.twitter),
          //     foregroundColor: Colors.black,
          //     backgroundColor: Colors.transparent,
          //   ),
          // ),
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
