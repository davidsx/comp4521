// # COMP 4521       #  LAU CHUN HONG        20349438        chlauap
import 'package:calendar/chat/chat_modal.dart';
import 'package:calendar/event/event_modal.dart';
import 'package:calendar/main.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Invitation extends StatefulWidget {
  final MsgModal msg;
  final bool isOwnMessage;
  Invitation(this.msg, this.isOwnMessage);
  @override
  _InvitationState createState() => _InvitationState();
}

class _InvitationState extends State<Invitation> {
  MsgModal msg;
  EventModal event;
  bool isOwnMessage;
  bool isGoing;

  @override
  void initState() {
    msg = widget.msg;
    isOwnMessage = widget.isOwnMessage;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width / 3 * 2;
    final dividerColor = const Color(0x1F000000);

    return StreamBuilder<DocumentSnapshot>(
        stream: Firestore.instance
            .collection('events')
            .document(msg.content)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            event = EventModal.fromFirestore(snapshot.data);
            isGoing = event.parti.contains(msg.idTo);
            return Row(
              mainAxisAlignment: isOwnMessage
                  ? MainAxisAlignment.end
                  : MainAxisAlignment.start,
              children: <Widget>[
                Container(
                  constraints: BoxConstraints(
                    maxWidth: width,
                    maxHeight: 300.0,
                    minHeight: 30.0,
                    minWidth: 80.0,
                  ),
                  margin: const EdgeInsets.all(4.0),
                  // padding: const EdgeInsets.all(10.0),
                  decoration: BoxDecoration(
                      color: isOwnMessage
                          ? Colors.greenAccent.shade100
                          : Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(10.0)),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: <Widget>[
                            CustomPaint(
                              painter: TypePainter(typecolor[event.type.index]),
                              child: Text(event.typeText()),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            title(),
                            time(),
                            location(),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: <Widget>[
                            Text(timestamp(msg.time)),
                            isOwnMessage
                                ? Icon(
                                    Icons.done_all,
                                    size: 12.0,
                                    color: msg.isRead
                                        ? Colors.blue
                                        : Colors.black38,
                                  )
                                : Container()
                          ],
                        ),
                      ),
                      // Divider(),
                      Visibility(
                        visible: !isOwnMessage,
                        child: Container(
                          height: 50.0,
                          child: Stack(
                            children: <Widget>[
                              Positioned(
                                left: 0,
                                bottom: 40.0,
                                child: Container(
                                  height: 2.0,
                                  width: width,
                                  color: dividerColor,
                                ),
                              ),
                              msg.isReacted
                                  ? Container()
                                  : Positioned(
                                      left: width / 2 - 1.0,
                                      bottom: 0.0,
                                      child: Container(
                                        height: 40.0,
                                        width: 2.0,
                                        color: dividerColor,
                                      ),
                                    ),
                              msg.isReacted
                                  ? Container()
                                  : Positioned(
                                      left: 0.0,
                                      bottom: 0.0,
                                      child: Container(
                                        decoration: BoxDecoration(
                                            borderRadius: BorderRadius.only(
                                                bottomLeft:
                                                    Radius.circular(10.0))),
                                        height: 40.0,
                                        width: width / 2,
                                        child: FlatButton(
                                          splashColor: Colors.transparent,
                                          onPressed: () => handleButton(false),
                                          child: Text("Decline"),
                                        ),
                                      ),
                                    ),
                              msg.isReacted
                                  ? Container()
                                  : Positioned(
                                      right: 0.0,
                                      bottom: 0.0,
                                      child: Container(
                                        decoration: BoxDecoration(
                                            borderRadius: BorderRadius.only(
                                                bottomLeft:
                                                    Radius.circular(10.0))),
                                        height: 40.0,
                                        width: width / 2,
                                        child: FlatButton(
                                          splashColor: Colors.transparent,
                                          onPressed: () => handleButton(true),
                                          child: Text("Accept"),
                                        ),
                                      ),
                                    ),
                              msg.isReacted
                                  ? Positioned(
                                      right: 0.0,
                                      bottom: 0.0,
                                      child: Container(
                                        decoration: BoxDecoration(
                                            borderRadius: BorderRadius.only(
                                                bottomLeft:
                                                    Radius.circular(10.0))),
                                        height: 40.0,
                                        width: width,
                                        child: Center(
                                            child: Text(
                                          isGoing ? "Going" : "Rejected",
                                          style: TextStyle(fontSize: 18.0),
                                        )),
                                      ),
                                    )
                                  : Container(),
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ],
            );
          }
          return Container();
        });
  }

  handleButton(bool accept) {
    String userId = msg.idTo;
    String peerId = msg.idFrom;
    String chatId;
    if (userId.hashCode <= peerId.hashCode) {
      chatId = '$userId-$peerId';
    } else {
      chatId = '$peerId-$userId';
    }
    Firestore.instance
        .collection("chat_room")
        .document(chatId)
        .collection(chatId)
        .document(msg.id)
        .updateData({'isReacted': true});

    if (accept) {
      Firestore.instance.collection("events").document(msg.content).updateData({
        'participants': FieldValue.arrayUnion([userId])
      });
    }

    setState(() {
      msg.isReacted = true;
    });
  }

  timestamp(DateTime d) {
    int hour = d.hour;
    String hourstr = (hour > 11 ? hour - 11 : hour).toString();
    int minute = d.minute;
    String minutestr =
        (minute < 10 ? '0' + minute.toString() : minute.toString());
    String apm = hour > 11 ? 'PM' : 'AM';
    return hourstr + ':' + minutestr + ' ' + apm;
  }

  title() => Padding(
      padding: EdgeInsets.symmetric(vertical: 5.0),
      child: Text(event.title,
          textAlign: TextAlign.center, style: TextStyle(fontSize: 26.0)));
  time() => Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          timeBlock(event.startDate, event.startTime),
          Icon(
            Icons.arrow_forward_ios,
            color: Colors.black,
            size: 15.0,
          ),
          timeBlock(event.endDate, event.endTime),
        ],
      );
  timeBlock(d, t) => Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Text(dateParser2(d), style: TextStyle(fontSize: 18.0)),
            Text(timeParser(t), style: TextStyle(fontSize: 22.0)),
          ],
        ),
      );

  location() => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: event.location != ''
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  // Icon(Icons.location_on, size: 15.0, color: Colors.black54),
                  Text("at " + event.location)
                ],
              )
            : Container(),
      );
}
