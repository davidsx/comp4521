// # COMP 4521       #  LAU CHUN HONG        20349438        chlauap
import 'package:calendar/bloc.dart';
import 'package:calendar/chat/chat_modal.dart';
import 'package:calendar/chat/chat_room.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NewChat extends StatefulWidget {
  @override
  _NewChatState createState() => _NewChatState();
}

class _NewChatState extends State<NewChat> {
  List<UserModal> users = List<UserModal>();
  
  String userId;
  SharedPreferences prefs;

  @override
  void initState() {
    super.initState();
    initPrefs();
  }

  initPrefs() async {
    prefs = await SharedPreferences.getInstance();
    userId = prefs.getString('id') ?? '';

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (userId == null) userId = InheritedCalendar.of(context).userId;
    
    return Scaffold(
      body: Card(
        margin: EdgeInsets.only(left: 10.0, right: 10.0, top: 0),
        elevation: 12.0,
        child: Container(
          margin: const EdgeInsets.all(5.0),
          padding: const EdgeInsets.only(bottom: 20.0),
          decoration: new BoxDecoration(
            color: Colors.white,
            borderRadius: new BorderRadius.all(Radius.circular(20.0)),
          ),
          child: SafeArea(
            child: Column(
              children: <Widget>[
                Container(
                  margin: const EdgeInsets.only(top: 15.0),
                  height: 5.0,
                  width: 30.0,
                  decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(2.5)),
                ),
                Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Text("New Chat",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 35.0,
                      )),
                ),
                Expanded(
                  child: Container(
                    child: StreamBuilder<QuerySnapshot>(
                      stream: Firestore.instance
                          .collection('chat_room')
                          .where('users', arrayContains: userId)
                          .orderBy('last_updated', descending: true)
                          .snapshots(),
                      builder: (context, roomSnapshot) {
                        if (!roomSnapshot.hasData) {
                          return Center(
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                  Theme.of(context).primaryColor),
                            ),
                          );
                        } else {
                          final List<DocumentSnapshot> roomDocuments =
                              roomSnapshot.data.documents;
                          List<String> peersId = List<String>();
                          for (var i = 0; i < roomDocuments.length; i++) {
                            List<dynamic> usersId = roomDocuments[i]['users'];
                            for (var j = 0; j < usersId.length; j++) {
                              String peerId = usersId[j].toString();
                              if (usersId[j].toString() != userId)
                                peersId.add(peerId);
                            }
                          }
                          return StreamBuilder<QuerySnapshot>(
                              stream: Firestore.instance
                                  .collection('users')
                                  .snapshots(),
                              builder: (context, userSnapshot) {
                                if (!userSnapshot.hasData) {
                                  return Center(
                                    child: CircularProgressIndicator(
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                          Theme.of(context).primaryColor),
                                    ),
                                  );
                                } else {
                                  final List<DocumentSnapshot> userDocuments =
                                      userSnapshot.data.documents;
                                      users = List<UserModal>();
                                  for (var i = 0; i < userDocuments.length; i++) {
                                    String peerId =
                                        userDocuments[i]['id'].toString();
                                    if (!peersId.contains(peerId) && peerId != userId)
                                      // print("$i");
                                      users.add(UserModal.fromFirestore(
                                          userDocuments[i]));
                                  }
                                  // print(users.length);
                                  return ListView.builder(
                                    padding: EdgeInsets.all(10.0),
                                    itemBuilder: (context, index) =>
                                        userBlock(users[index]),
                                    itemCount: users.length,
                                  );
                                }
                              });
                        }
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  userBlock(UserModal peer) {
    return ListTile(
      onTap: () => Navigator.of(context)
          .push(MaterialPageRoute(builder: (context) => ChatRoom(peer))),
      leading: peer.photo == ''
          ? CircleAvatar(radius: 25.0, foregroundColor: Colors.orange)
          : Material(
              child: CachedNetworkImage(
                placeholder: (context, url) => Container(
                      child: CircularProgressIndicator(
                        strokeWidth: 1.0,
                        valueColor:
                            AlwaysStoppedAnimation<Color>(Colors.orange),
                      ),
                      width: 50.0,
                      height: 50.0,
                      padding: EdgeInsets.all(15.0),
                    ),
                imageUrl: peer.photo,
                width: 50.0,
                height: 50.0,
                fit: BoxFit.cover,
              ),
              borderRadius: BorderRadius.all(Radius.circular(25.0)),
              clipBehavior: Clip.hardEdge,
            ),
      title: Text(peer.username),
    );
  }
}
