// # COMP 4521       #  LAU CHUN HONG        20349438        chlauap
import 'package:cached_network_image/cached_network_image.dart';
import 'package:calendar/chat/chat_modal.dart';
import 'package:calendar/event/event_modal.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class InviteEvent extends StatefulWidget {
  final EventModal event;
  InviteEvent(this.event);
  @override
  _InviteEventState createState() => _InviteEventState();
}

class _InviteEventState extends State<InviteEvent> {
  double photoRadius = 50.0;
  List<bool> isInvited;
  List<UserModal> users;
  EventModal event;

  SharedPreferences prefs;
  String userId;

  @override
  void initState() {
    super.initState();
    isInvited = List<bool>.filled(100, false);
    event = widget.event;
    initPrefs();
  }

  initPrefs() async {
    prefs = await SharedPreferences.getInstance();
    userId = prefs.getString('id') ?? '';
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height / 2;
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Card(
        margin: EdgeInsets.only(left: 10.0, right: 10.0, top: height - 40),
        elevation: 12.0,
        child: Container(
          margin: const EdgeInsets.all(5.0),
          padding: const EdgeInsets.only(bottom: 20.0),
          decoration: new BoxDecoration(
            color: Colors.white,
            borderRadius: new BorderRadius.all(Radius.circular(20.0)),
          ),
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
                child: Text("Invite",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 35.0,
                    )),
              ),
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                    stream: Firestore.instance.collection('users').snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        if (snapshot.data.documents.length > 0) {
                          users = List<UserModal>.generate(
                              snapshot.data.documents.length,
                              (index) => UserModal.fromFirestore(
                                  snapshot.data.documents[index]));
                          return GridView.builder(
                            padding: EdgeInsets.symmetric(vertical: 20.0),
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 3),
                            itemCount: snapshot.data.documents.length,
                            shrinkWrap: true,
                            itemBuilder: (context, index) {
                              final UserModal user = UserModal.fromFirestore(
                                  snapshot.data.documents[index]);
                              return userBlock(user, index);
                            },
                          );
                        }
                      }
                      return Center(child: CircularProgressIndicator());
                    }),
              ),
              Container(
                height: 50.0,
                child: RaisedButton(
                  onPressed: sendInvitation,
                  child: SizedBox(
                    width: 100.0,
                    child: Center(
                      child: Text(
                        'Invite',
                        style: TextStyle(color: Colors.white, fontSize: 20.0),
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  sendInvitation() {
    List<String> usersId = List<String>();
    for (var i = 0; i < isInvited.length; i++) {
      if (isInvited[i]) usersId.add(users[i].id);
    }
    if (usersId.isNotEmpty) {
      for (var i = 0; i < usersId.length; i++) {
        String peerId = usersId[i];
        String chatId;
        if (userId.hashCode <= peerId.hashCode) {
          chatId = '$userId-$peerId';
        } else {
          chatId = '$peerId-$userId';
        }
        int now = DateTime.now().millisecondsSinceEpoch;
        Firestore.instance
            .collection("chat_room")
            .document(chatId)
            .collection(chatId)
            .add({
          'idFrom': userId,
          'idTo': peerId,
          'timestamp': now,
          'content': event.id,
          'type': 1, // 1 is invite message
          'isRead': false,
          'isReacted': false,
        }).then((val) {
          print("message add");
        }).catchError((err) {
          print(err);
        });

        Firestore.instance.collection("chat_room").document(chatId).setData({
          'users': [userId, peerId],
          'last_updated': now,
        }).then((val) {
          print("message updated");
        }).catchError((err) {
          print(err);
        });
      }
    }
    Navigator.of(context).pop(usersId);
  }

  invite(int i) {
    setState(() {
      isInvited[i] = !isInvited[i];
    });
  }

  userBlock(UserModal user, int index) {
    if (event.parti.contains(user.id)) {
      return Container();
    } else
      return GestureDetector(
        onTap: () => invite(index),
        child: Column(
          children: <Widget>[
            CustomPaint(
              painter: isInvited[index] ? InvitePainter() : null,
              child: user.photo == ""
                  ? CircleAvatar(
                      radius: photoRadius / 2, foregroundColor: Colors.orange)
                  : Material(
                      child: CachedNetworkImage(
                        placeholder: (context, url) => Container(
                              child: CircularProgressIndicator(
                                strokeWidth: 1.0,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.orange),
                              ),
                              width: photoRadius,
                              height: photoRadius,
                              padding: EdgeInsets.all(15.0),
                            ),
                        imageUrl: user.photo,
                        width: photoRadius,
                        height: photoRadius,
                        fit: BoxFit.cover,
                      ),
                      borderRadius: BorderRadius.all(Radius.circular(25.0)),
                      clipBehavior: Clip.hardEdge,
                    ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(user.username),
            ),
          ],
        ),
      );
  }
}

class InvitePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = Colors.orange
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0;
    Offset center = Offset(size.width / 2, size.height / 2);
    double radius = 30.0;
    canvas.drawCircle(center, radius, paint);
  }

  @override
  bool shouldRepaint(InvitePainter oldDelegate) => false;

  @override
  bool shouldRebuildSemantics(InvitePainter oldDelegate) => false;
}
