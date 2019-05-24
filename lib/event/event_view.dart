// # COMP 4521       #  LAU CHUN HONG        20349438        chlauap
import 'package:calendar/event/event_detail.dart';
import 'package:calendar/event/event_modal.dart';
import 'package:calendar/main.dart';
import 'package:calendar/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Event extends StatefulWidget {
  @override
  _EventState createState() => _EventState();
}

class _EventState extends State<Event> {
  List<EventModal> events;
  List<String> eventsId;

  SharedPreferences prefs;
  String userId;

  DateTime selectedDay;

  @override
  void initState() {
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
    final inherited = InheritedCalendar.of(context);
    selectedDay = inherited.bloc.selectedDay;
    int selectedDayEpoch = selectedDay.millisecondsSinceEpoch;

    return StreamBuilder<DateTime>(
      stream: inherited.bloc.selectedDayStream,
      builder: (BuildContext context, selectedDaySnapshot) {
        if (selectedDaySnapshot.hasData) {
          selectedDay = selectedDaySnapshot.data;
          selectedDayEpoch = selectedDay.millisecondsSinceEpoch;
        }
        return StreamBuilder<QuerySnapshot>(
            stream: Firestore.instance
                .collection('events')
                .where('participants', arrayContains: userId)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasData) if (snapshot.data.documents.length > 0) {
                events = List<EventModal>();
                for (var i = 0; i < snapshot.data.documents.length; i++) {
                  DocumentSnapshot document = snapshot.data.documents[i];
                  if (document['startDate'] <= selectedDayEpoch &&
                      document['endDate'] >= selectedDayEpoch) {
                    events.add(
                        EventModal.fromFirestore(snapshot.data.documents[i]));
                  }
                }
                if (events.length == 0)
                  return Center(child: Text("No event so far"));
                else
                  return Stack(
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Row(
                          children: <Widget>[
                            todayLabel(selectedDay),
                            Expanded(
                              child: ListView.builder(
                                itemCount: events.length,
                                itemBuilder: (context, i) => listitem(i),
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
                  );
              }
              return Center(child: Text("No event so far"));
            });
        // return Center(child: Text("No event so far"));
      },
    );
  }

  todayLabel(DateTime selectedDay) => Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: <Widget>[
            Text(
              selectedDay.day.toString(),
              style: TextStyle(fontSize: 30.0),
            ),
            Text(
              monthlist[selectedDay.month - 1],
              style: TextStyle(fontSize: 20.0),
            )
          ],
        ),
      );

  // getselecteddaylist(List<EventModal> eventlist, DateTime selectedDay) {
  //   List<EventModal> list = new List<EventModal>();
  //   for (int i = 0; i < eventlist.length; i++)
  //     if (isSameDate(eventlist[i].startDate, selectedDay)) {
  //       list.add(eventlist[i]);
  //     }
  //   return list;
  // }

  listitem(int i) {
    EventModal event = events[i];
    DateTime d = selectedDay;

    TimeOfDay st =
        isSameDate(d, event.startDate) ? event.startTime : TimeOfDay(hour: 0, minute: 0);
    TimeOfDay et =
        isSameDate(d, event.endDate) ? event.endTime : TimeOfDay(hour: 0, minute: 0);
        
    // DateTime sd = d.add(Duration(hours: st.hour, minutes: st.minute));
    // DateTime ed = d.add(Duration(hours: et.hour, minutes: et.minute));

    return GestureDetector(
      onTap: () => Navigator.of(context)
          .push(MaterialPageRoute(builder: (context) => EventDetail(event))),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 10.0),
        height: 65.0,
        child: Row(
          children: <Widget>[
            Container(
              color: typecolor[event.type.index],
              width: 5.0,
              height: double.maxFinite,
              // child: Text("data"),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  isSameDate(d, event.startDate) || isSameDate(d, event.endDate)
                      ? Text(
                          timeParser(st) +
                              ' - ' +
                              timeParser(et),
                          style: TextStyle(fontSize: 15.0),
                        )
                      : Text("All day"),
                  Text(
                    event.title,
                    style: TextStyle(fontSize: 20.0),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: event.location != ''
                        ? Row(
                            children: <Widget>[
                              Icon(Icons.location_on,
                                  size: 15.0, color: Colors.black54),
                              Text(event.location)
                            ],
                          )
                        : Container(),
                  ),
                ],
              ),
            ),
            Expanded(
                child: Align(
                    alignment: Alignment.centerRight,
                    child: Icon(Icons.arrow_forward_ios)))
          ],
        ),
      ),
    );
  }

  // timeParser(hour, minute) {
  //   return (hour > 10 ? hour.toString() : '0' + hour.toString()) +
  //       ':' +
  //       (minute > 10 ? minute.toString() : '0' + minute.toString());
  // }
}
