// # COMP 4521       #  LAU CHUN HONG        20349438        chlauap
import 'package:calendar/bloc.dart';
import 'package:calendar/chat/chat_modal.dart';
import 'package:calendar/chat/chat_new.dart';
import 'package:calendar/chat/chat_room.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  String userId;
  List<UserModal> users;
  List<String> chatId;

  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    // userId = widget.userId;
  }

  @override
  Widget build(BuildContext context) {
    if (userId == null) userId = InheritedCalendar.of(context).userId;
    return Scaffold(
      key: _scaffoldKey,
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Text("Chat",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 35.0,
                      )),
                  IconButton(
                    color: Colors.black,
                    onPressed: () {
                      _scaffoldKey.currentState.showBottomSheet<List<String>>(
                    (builder) => NewChat());
                    },
                    icon: Icon(Icons.add),
                    iconSize: 35.0,
                  )
                ],
              ),
            ),
            Expanded(
              child: Container(
                child: StreamBuilder(
                  stream: Firestore.instance
                      .collection('chat_room')
                      .where('users', arrayContains: userId)
                      .orderBy('last_updated', descending: true)
                      .snapshots(),
                  builder: (context, chatSnapshot) {
                    if (!chatSnapshot.hasData) {
                      return Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                              Theme.of(context).primaryColor),
                        ),
                      );
                    } else {
                      final List<DocumentSnapshot> documents =
                          chatSnapshot.data.documents;
                      chatId = List<String>.generate(
                          documents.length, (i) => documents[i].documentID);
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
                              final List<DocumentSnapshot> documents =
                                  userSnapshot.data.documents;
                              users = List<UserModal>.generate(documents.length,
                                  (i) => UserModal.fromFirestore(documents[i]));
                              return ListView.builder(
                                padding: EdgeInsets.all(10.0),
                                itemBuilder: (context, index) =>
                                    userBlock(chatId[index]),
                                itemCount: chatSnapshot.data.documents.length,
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
    );
  }

  userBlock(String chatId) {
    return StreamBuilder<DocumentSnapshot>(
        stream: Firestore.instance
            .collection("chat_room")
            .document(chatId)
            .snapshots(),
        builder: (context, roomSnapshot) {
          if (roomSnapshot.hasData) {
            List<String> chatroomUsersId = List<String>.generate(
                roomSnapshot.data.data['users'].length,
                (i) => roomSnapshot.data.data['users'][i].toString());
            final peerId = chatroomUsersId.firstWhere((id) => id != userId);
            final UserModal peer =
                users[users.indexWhere((UserModal user) => user.id == peerId)];
            return StreamBuilder<QuerySnapshot>(
                stream: Firestore.instance
                    .collection("chat_room")
                    .document(chatId)
                    .collection(chatId)
                    .orderBy("timestamp", descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    final List<DocumentSnapshot> documents =
                        snapshot.data.documents;
                    MsgModal message;
                    if (documents.isNotEmpty) {
                      message = MsgModal.fromFirestore(documents[0]);
                      String msg;
                      switch (message.type) {
                        case 0:
                          msg = message.content;
                          break;
                        case 1:
                          msg = "Invitation";
                          break;
                      }
                      return ListTile(
                        onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                                builder: (context) => ChatRoom(peer))),
                        leading: peer.photo == ''
                            ? CircleAvatar(
                                radius: 25.0, foregroundColor: Colors.orange)
                            : Material(
                                child: CachedNetworkImage(
                                  placeholder: (context, url) => Container(
                                        child: CircularProgressIndicator(
                                          strokeWidth: 1.0,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                  Colors.orange),
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
                                borderRadius:
                                    BorderRadius.all(Radius.circular(25.0)),
                                clipBehavior: Clip.hardEdge,
                              ),
                        title: Text(peer.username),
                        subtitle: Stack(
                          overflow: Overflow.clip,
                          children: <Widget>[
                            message.idFrom == userId
                                ? Icon(Icons.forward)
                                : Container(),
                            Positioned(
                              top: 5,
                              // height: double.maxFinite,
                              left: message.idFrom == userId ? 25 : 0,
                              child: Text(msg),
                            ),
                          ],
                        ),
                        trailing: message == null
                            ? Container(width: 0, height: 0)
                            : Text(timestamp(message.time)),
                      );
                    }
                  }
                  return Container();
                });
          }
          return Container();
        });
  }

  String timestamp(DateTime d) {
    int hour = d.hour;
    String hourstr = (hour > 11 ? hour - 11 : hour).toString();
    int minute = d.minute;
    String minutestr =
        (minute < 10 ? '0' + minute.toString() : minute.toString());
    String apm = hour > 11 ? 'PM' : 'AM';
    return hourstr + ':' + minutestr + ' ' + apm;
  }
}
