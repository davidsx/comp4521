// # COMP 4521       #  LAU CHUN HONG        20349438        chlauap
import 'package:cached_network_image/cached_network_image.dart';
import 'package:calendar/event/event_invite.dart';
import 'package:calendar/event/event_modal.dart';
import 'package:calendar/main.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EventDetail extends StatefulWidget {
  EventDetail(this.event, {Key key}) : super(key: key);
  final EventModal event;

  _EventDetailState createState() => _EventDetailState();
}

class _EventDetailState extends State<EventDetail> {
  EventModal event;
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  SharedPreferences prefs;
  String userId;

  @override
  void initState() {
    event = widget.event;
    initPrefs();
    super.initState();
  }

  initPrefs() async {
    prefs = await SharedPreferences.getInstance();
    userId = prefs.getString('id') ?? '';
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        elevation: 0.0,
        leading: BackButton(
          color: Colors.orange,
        ),
        // actions: <Widget>[
        //   RaisedButton()
        // ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(30.0),
        child: Column(
          children: <Widget>[
            Text(
              event.title,
              style: TextStyle(fontSize: 45.0),
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  event.location == ''
                      ? SizedBox(
                          height: 16,
                          width: 16,
                        )
                      : Text(
                          "at " + event.location,
                          style: TextStyle(fontSize: 16.0),
                        ),
                  CustomPaint(
                    painter: TypePainter(typecolor[event.type.index]),
                    child: Text(
                      event.typeText(),
                      style: TextStyle(fontSize: 16.0),
                    ),
                  )
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0)),
                  child: SizedBox.fromSize(
                    size: Size(140.0, 140.0),
                    child: Container(
                      padding: EdgeInsets.all(10.0),
                      child: Column(
                        children: <Widget>[
                          Text("FROM: "),
                          Expanded(
                            flex: 1,
                            child: Align(
                              alignment: Alignment.bottomCenter,
                              child: Text(
                                dateParser3(event.startDate),
                                style: TextStyle(fontSize: 20.0),
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Align(
                              alignment: Alignment.topCenter,
                              child: Text(
                                timeParser(event.startTime),
                                style: TextStyle(
                                    fontSize: 25.0,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Icon(
                  Icons.more_horiz,
                  size: 50.0,
                ),
                Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0)),
                  child: SizedBox.fromSize(
                    size: Size(140.0, 140.0),
                    child: Container(
                      padding: EdgeInsets.all(10.0),
                      child: Column(
                        children: <Widget>[
                          Text("TO:"),
                          Expanded(
                            flex: 1,
                            child: Align(
                              alignment: Alignment.bottomCenter,
                              child: Text(
                                dateParser3(event.endDate),
                                style: TextStyle(fontSize: 20.0),
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Align(
                              alignment: Alignment.topCenter,
                              child: Text(
                                timeParser(event.endTime),
                                style: TextStyle(
                                    fontSize: 25.0,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Container(
              width: double.maxFinite,
              height: 210.0,
              padding: const EdgeInsets.all(10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10.0),
                    child: Text(
                      "Pariticipants",
                      style: TextStyle(fontSize: 26.0),
                    ),
                  ),
                  Expanded(
                    child: StreamBuilder<QuerySnapshot>(
                        stream:
                            Firestore.instance.collection('users').snapshots(),
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            if (snapshot.data.documents.length > 0) {
                              final documents = snapshot.data.documents;
                              List<String> icons = List<String>();
                              print(event.parti);
                              for (var i = 0; i < documents.length; i++) {
                                String userId = documents[i]['id'].toString();
                                print(userId);
                                if (event.parti.contains(userId)) {
                                  icons.add(documents[i]['photoUrl']);
                                }
                              }
                              return GridView.builder(
                                gridDelegate:
                                    SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: 5),
                                itemCount: icons.length + 1,
                                itemBuilder: (context, i) => i == icons.length
                                    ? iconAdd()
                                    : iconBlock(icons[i], documents[i]['username']),
                              );
                            }
                          }
                          return Container();
                        }),
                  ),
                ],
              ),
            ),
            event.note == ''
                ? Spacer()
                : Expanded(child: Center(child: Text("Note: \n" + event.note))),
            RaisedButton(
              color: Colors.red,
              shape: BeveledRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              onPressed: () {
                Firestore.instance
                    .collection("events")
                    .document(event.id)
                    .updateData({
                  'participants': FieldValue.arrayRemove([userId])
                });

                Navigator.of(context).pop();
              },
              child: SizedBox(
                width: 150.0,
                height: 50.0,
                child: Center(
                  child: Text(
                    'Delete Event',
                    style: TextStyle(color: Colors.white, fontSize: 24.0),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  iconAdd() => GestureDetector(
        onTap: () {
          _scaffoldKey.currentState
              .showBottomSheet<List<String>>((builder) => InviteEvent(event));
        },
        child: Container(
          margin: EdgeInsets.all(4.0),
          width: 50.0,
          height: 50.0,
          child: Icon(Icons.add, color: Colors.orange),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.orange, width: 3.0),
            borderRadius: BorderRadius.all(Radius.circular(25.0)),
          ),
        ),
      );

  iconBlock(String url, String replacing) => url == ''
      ? Container(
          margin: EdgeInsets.all(4.0),
          width: 50.0,
          height: 50.0,
          child: Center(child: Text(replacing, textAlign: TextAlign.center,)),
          decoration: BoxDecoration(
            color: Colors.orange,
            border: Border.all(color: Colors.orange, width: 3.0),
            borderRadius: BorderRadius.all(Radius.circular(25.0)),
          ),
        )
      : Container(
          margin: EdgeInsets.all(4.0),
          child: Material(
            child: CachedNetworkImage(
              placeholder: (context, url) => Container(
                    child: CircularProgressIndicator(
                      strokeWidth: 1.0,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
                    ),
                    width: 50.0,
                    height: 50.0,
                    padding: EdgeInsets.all(15.0),
                  ),
              imageUrl: url,
              width: 50.0,
              height: 50.0,
              fit: BoxFit.cover,
            ),
            borderRadius: BorderRadius.all(Radius.circular(25.0)),
            clipBehavior: Clip.hardEdge,
          ),
        );
}
