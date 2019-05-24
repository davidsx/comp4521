// # COMP 4521       #  LAU CHUN HONG        20349438        chlauap
import 'dart:async';
import 'dart:math';

import 'package:calendar/event/event_modal.dart';
import 'package:calendar/main.dart';
import 'package:calendar/bloc.dart';
import 'package:calendar/schedule/calendar_event.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MonthYear extends StatefulWidget {
  MonthYear({Key key}) : super(key: key);

  _MonthYearState createState() => _MonthYearState();
}

class _MonthYearState extends State<MonthYear> {
  InheritedCalendar _inheritedCalendar;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _inheritedCalendar = InheritedCalendar.of(context);
    final bloc = _inheritedCalendar.bloc;

    return StreamBuilder<int>(
        stream: bloc.pageIndex,
        // initialData: initPageIndex,
        builder: (context, snapshot) {
          return PageView.builder(
            controller: _inheritedCalendar.monthyearController,
            scrollDirection: Axis.vertical,
            physics: NeverScrollableScrollPhysics(),
            itemCount: 10 * 12, // 10 years, 12 month
            itemBuilder: (context, position) {
              return Text(
                monthlist[position % 12].toString() +
                    ', ' +
                    yearlist[position ~/ 12].toString(),
                style: TextStyle(color: Colors.black, fontSize: 23.5),
              );
            },
          );
        });
  }
}

class Calendar extends StatefulWidget {
  @override
  _CalendarState createState() => _CalendarState();
}

class _CalendarState extends State<Calendar> {
  InheritedCalendar _inheritedCalendar;
  // GlobalKey _pagekey = GlobalKey();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _inheritedCalendar = InheritedCalendar.of(context);
    final bloc = _inheritedCalendar.bloc;

    return StreamBuilder<DateTime>(
        stream: bloc.selectedDayStream,
        // initialData: DateTime.now(),
        builder: (context, snapshot) {
          // if (snapshot.hasData) {
          return Container(
            child: PageView.builder(
              controller: _inheritedCalendar.calendarController,
              scrollDirection: Axis.vertical,
              onPageChanged: (position) {
                bloc.calendarEvent.add(PageChange(position));
                _inheritedCalendar.headerAnimatedTo(position);
              },
              itemCount: 10 * 12, // 10 years, 12 month
              itemBuilder: (context, position) {
                int gridyear = yearlist[position ~/ 12];
                int gridmonth = position % 12 + 1;
                return Container(
                  child: Column(
                    children: <Widget>[
                      Days(gridmonth, gridyear),
                    ],
                  ),
                );
              },
            ),
          );
          // }
          // return Container();
        });
  }
}

class Days extends StatefulWidget {
  Days(this.month, this.year);

  final int month, year;

  @override
  _DaysState createState() => _DaysState();
}

class _DaysState extends State<Days> {
  @override
  Widget build(BuildContext context) {
    DateTime startDay = DateTime(widget.year, widget.month, 1);
    DateTime calStart = startDay.subtract(Duration(days: startDay.weekday - 1));
    DateTime endDay = DateTime(widget.year, widget.month + 1, 0);
    DateTime calEnd = endDay.add(Duration(days: 7 - endDay.weekday));

    final bloc = InheritedCalendar.of(context).bloc;

    return StreamBuilder<int>(
        stream: bloc.pageIndex,
        // initialData: initPageIndex,
        builder: (context, pageSnapshot) {
          return Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0),
            ),
            child: GridView.builder(
                physics: NeverScrollableScrollPhysics(),
                padding: EdgeInsets.all(0.0),
                shrinkWrap: true,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 7,
                ),
                itemCount: calEnd.difference(calStart).inDays + 1 + 7,
                itemBuilder: (context, i) {
                  if (i < 7)
                    return Container(
                      child: Text(
                        weeklistCap[i],
                        style: TextStyle(
                            fontSize: 15.0,
                            color: Colors.black,
                            fontWeight: FontWeight.w600),
                      ),
                      alignment: Alignment.center,
                    );
                  else {
                    int dayi = i - 7;
                    DateTime cur = calStart.add(Duration(days: dayi));
                    return Day(
                        cur.isBefore(startDay) || cur.isAfter(endDay), cur);
                  }
                }),
          );
        });
  }
}

class Day extends StatefulWidget {
  final bool notInCal;
  final DateTime day;
  Day(this.notInCal, this.day);

  @override
  _DayState createState() => _DayState();
}

class _DayState extends State<Day> {
  @override
  void initState() {
    initPrefs();
    super.initState();
  }

  SharedPreferences prefs;
  String userId = "username";

  void initPrefs() async {
    prefs = await SharedPreferences.getInstance();
    userId = prefs.getString('id');
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final inherited = InheritedCalendar.of(context);
    final bloc = inherited.bloc;
    final selectedDay = bloc.selectedDay;
    final epoch = widget.day.millisecondsSinceEpoch;

    int curDay = widget.day.day;
    bool isSelected = isSameDate(widget.day, selectedDay);
    bool isToday = isSameDate(widget.day, DateTime.now());
    bool isSunday = widget.day.weekday == 7;
    Color textColor =
        widget.notInCal ? Colors.grey : (isSunday ? Colors.red : Colors.black);
    Color paintColor = isSelected ? Colors.orange : Colors.transparent;
    return StreamBuilder<QuerySnapshot>(
        stream: Firestore.instance
            .collection('events')
            .where('participants', arrayContains: userId)
            .snapshots(),
        builder: (context, snapshot) {
          List<Color> colors = List<Color>();
          if (snapshot.hasData) if (snapshot.data.documents.length > 0) {
            for (var i = 0; i < snapshot.data.documents.length; i++) {
              DocumentSnapshot document = snapshot.data.documents[i];
              if (document['startDate'] <= epoch &&
                  document['endDate'] >= epoch) {
                Type type = Type.values[typelist.indexOf(document['type'])];
                colors.add(typecolor[type.index]);
              }
            }
          }
          return GestureDetector(
              onTap: () {
                if (widget.notInCal) {
                  inherited.pageAnimatedTo(getPageIndex(widget.day));
                  Timer(Duration(milliseconds: 500),
                      () => bloc.calendarEvent.add(DayTap(widget.day)));
                } else
                  bloc.calendarEvent.add(DayTap(widget.day));
              },
              child: Container(
                margin: EdgeInsets.all(8.0),
                // decoration: BoxDecoration(
                //   shape: BoxShape.circle,
                //   color: paintColor,
                // ),
                child: CustomPaint(
                  painter: DayPainter(paintColor, colors),
                  child: Text(
                    '$curDay',
                    style: TextStyle(
                      fontSize: 18.0,
                      color: textColor,
                      fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ),
                alignment: Alignment.center,
              ));
          // return Container();
        });
  }

  isNotInCal(int pageIndex) {
    int month = pageIndex % 12 + 1;
    int year = yearlist[pageIndex ~/ 12];
    DateTime startDay = DateTime.utc(year, month, 1);
    DateTime endDay = DateTime.utc(year, month + 1, 0);
    return widget.day.isBefore(startDay) || widget.day.isAfter(endDay);
  }
}

class DayPainter extends CustomPainter {
  DayPainter(this.color, this.colors);
  final List<Color> colors;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    int eventlen = colors.length;
    if (eventlen > 0) {
      List<Paint> line = new List<Paint>.generate(
          eventlen,
          (i) => Paint()
            ..color = colors[i]
            ..style = PaintingStyle.stroke
            ..strokeWidth = 3.0);
      double sweepAngle = 2 * pi / eventlen;
      List<double> startAngle = new List<double>.generate(
          eventlen,
          (i) =>
              (-pi / 2) -
              (pi / eventlen) +
              (sweepAngle * i) +
              (eventlen == 1 && i == 0 ? 0 : pi / 60));
      var center = Offset(size.width / 2, size.height / 2);
      double radius = size.height / 2 + 7.0;

      for (int i = 0; i < eventlen; i++)
        canvas.drawArc(
            new Rect.fromCircle(center: center, radius: radius),
            startAngle[i],
            sweepAngle - (eventlen == 1 ? 0 : pi / 30),
            false,
            line[i]);
    }

    var center = Offset(size.width / 2, size.height + 7.0);
    // draw dot if selected
    if (color != Colors.transparent) {
      Paint outline = Paint()..color = Colors.white;
      canvas.drawCircle(center, 6.0, outline);
      Paint paint = Paint()..color = color;
      canvas.drawCircle(center, 4.0, paint);
    }
  }

  @override
  bool shouldRepaint(DayPainter oldDelegate) => true;

  @override
  bool shouldRebuildSemantics(DayPainter oldDelegate) => true;
}
