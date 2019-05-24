// # COMP 4521       #  LAU CHUN HONG        20349438        chlauap
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:calendar/bloc.dart';
import 'package:calendar/chat/chat_modal.dart';
import 'package:calendar/event/event_modal.dart';
import 'package:calendar/main.dart';
import 'package:calendar/screen/signin_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class UserScreen extends StatefulWidget {
  @override
  _UserScreenState createState() => _UserScreenState();
}

class _UserScreenState extends State<UserScreen> {
  UserModal user;
  SharedPreferences prefs;

  String userId = '';
  String username = '';
  String password = '';
  String photoUrl = '';

  String imageUrl;
  File imageFile;

  bool isLoading;

  @override
  void initState() {
    user = UserModal.setUp();
    initUser();
    super.initState();
  }

  void initUser() async {
    prefs = await SharedPreferences.getInstance();
    user = UserModal.fromPrefs(prefs);
    userId = user.id;

    setState(() {});
  }

  Future getImage() async {
    File image = await ImagePicker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        imageFile = image;
        isLoading = true;
      });
    }
    uploadFile();
  }

  Future uploadFile() async {
    String fileName = userId;
    StorageReference reference = FirebaseStorage.instance.ref().child(fileName);
    StorageUploadTask uploadTask = reference.putFile(imageFile);
    StorageTaskSnapshot storageTaskSnapshot;
    uploadTask.onComplete.then((value) {
      if (value.error == null) {
        storageTaskSnapshot = value;
        storageTaskSnapshot.ref.getDownloadURL().then((downloadUrl) {
          photoUrl = downloadUrl;
          Firestore.instance
              .collection('users')
              .document(userId)
              .updateData({'photoUrl': photoUrl}).then((data) async {
            await prefs.setString('photoUrl', photoUrl);
            setState(() {
              isLoading = false;
            });
            Fluttertoast.showToast(msg: "Upload success");
          }).catchError((err) {
            setState(() {
              isLoading = false;
            });
            Fluttertoast.showToast(msg: err.toString());
          });
        }, onError: (err) {
          setState(() {
            isLoading = false;
          });
          Fluttertoast.showToast(msg: 'This file is not an image');
        });
      } else {
        setState(() {
          isLoading = false;
        });
        Fluttertoast.showToast(msg: 'This file is not an image');
      }
    }, onError: (err) {
      setState(() {
        isLoading = false;
      });
      Fluttertoast.showToast(msg: err.toString());
    });
  }

  @override
  Widget build(BuildContext context) {
    final inherited = InheritedCalendar.of(context);
    return Scaffold(
      body: Column(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Text("Profile",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 35.0,
                    )),
              ],
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    user.photo == ''
                        ? CircleAvatar(
                            radius: 75.0,
                            foregroundColor: Colors.orange,
                            backgroundColor: Colors.orange)
                        : Material(
                            child: CachedNetworkImage(
                              placeholder: (context, url) => Container(
                                    child: CircularProgressIndicator(
                                      strokeWidth: 1.0,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                          Colors.orange),
                                    ),
                                    width: 150.0,
                                    height: 150.0,
                                    padding: EdgeInsets.all(15.0),
                                  ),
                              imageUrl: user.photo,
                              width: 150.0,
                              height: 150.0,
                              fit: BoxFit.cover,
                            ),
                            borderRadius:
                                BorderRadius.all(Radius.circular(25.0)),
                            clipBehavior: Clip.hardEdge,
                          ),
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Text(
                        user.username,
                        style: TextStyle(fontSize: 30.0),
                      ),
                    )
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 50.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Container(
                            width: 55,
                            height: 55,
                            child: RaisedButton(
                              shape: CircleBorder(),
                              color: Colors.white,
                              child: Icon(
                                Icons.exit_to_app,
                                color: Colors.grey,
                                size: 25.0,
                              ),
                              onPressed: handleSignOut,
                            ),
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.only(top: 10.0, bottom: 40),
                            child: Text('Logout'),
                          )
                        ],
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Container(
                            padding: EdgeInsets.only(top: 40),
                            child: RaisedButton(
                              shape: CircleBorder(),
                              color: Colors.orange,
                              child: Icon(
                                Icons.photo_camera,
                                color: Colors.white,
                                size: 30.0,
                              ),
                              onPressed: () {},
                            ),
                          ),
                          Text('Change Icon')
                        ],
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Container(
                            height: 55.0,
                            width: 55.0,
                            child: RaisedButton(
                              shape: CircleBorder(),
                              color: Colors.white,
                              child: Icon(
                                Icons.edit,
                                color: Colors.grey,
                                size: 25.0,
                              ),
                              onPressed: () {},
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(top: 10.0, bottom: 40.0),
                            child: Text('Edit Info'),
                          )
                        ],
                      ),
                    ],
                  ),
                ),
                // SizedBox(height: 20.0),
                // Text('Upcoming Event'),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Card(
                    elevation: 2.0,
                    margin: EdgeInsets.all(40.0),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                          vertical: 10.0, horizontal: 15.0),
                      width: 300,
                      height: 200,
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(40.0)),
                      child: StreamBuilder<QuerySnapshot>(
                          stream: Firestore.instance
                              .collection('events')
                              .where('participants',
                                  arrayContains: inherited.userId)
                              .where('start',
                                  isGreaterThanOrEqualTo:
                                      DateTime.now().millisecondsSinceEpoch)
                              .orderBy('start')
                              .snapshots(),
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              if (snapshot.data.documents.length > 0) {
                                EventModal event = EventModal.fromFirestore(
                                    snapshot.data.documents[0]);
                                return eventDetail(event);
                              }
                            }
                            return Center(
                                child: Text("You have no event coming"));
                          }),
                    ),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  eventDetail(EventModal event) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(left: 15.0),
            child: CustomPaint(
              painter: TypePainter(event.color),
              child: Text(
                  dateParser(event.startDate) +
                      ' ' +
                      timeParser(event.startTime),
                  style: TextStyle(color: Colors.black.withOpacity(0.7), fontSize: 18)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10.0),
            child: Text(event.title,
                style: TextStyle(fontSize: 40.0, fontWeight: FontWeight.bold)),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 20.0),
            child: Text("Note: " + event.note),
          )
        ],
      );

  Future<Null> handleSignOut() async {
    this.setState(() {
      isLoading = true;
    });

    await FirebaseAuth.instance.signOut();
    await googleSignIn.disconnect();
    await googleSignIn.signOut();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    InheritedCalendar.of(context).bloc.dispose();

    this.setState(() {
      isLoading = false;
    });

    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => SignInScreen()),
        (Route<dynamic> route) => false);
  }
}
