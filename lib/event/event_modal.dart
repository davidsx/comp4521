// # COMP 4521       #  LAU CHUN HONG        20349438        chlauap
import 'package:calendar/main.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class EventModal {
  String id;
  DateTime startDate, endDate;
  TimeOfDay startTime, endTime;
  APM startapm, endapm;
  // EventDuration duration;
  String title, location, note;
  Repeat repeat;
  // Color color;
  Type type;
  MultiType multitype;
  bool allday;
  bool setup;
  List<String> parti;

  EventModal.fromFirestore(DocumentSnapshot document) {
    id = document.documentID;
    DateTime start = DateTime.fromMillisecondsSinceEpoch(document['start']);
    DateTime end = DateTime.fromMillisecondsSinceEpoch(document['end']);
    startDate = DateTime(start.year, start.month, start.day);
    endDate = DateTime(end.year, end.month, end.day);
    startTime = TimeOfDay.fromDateTime(start);
    endTime = TimeOfDay.fromDateTime(end);
    title = document['title'];
    location = document['location'];
    note = document['note'];
    // repeat = Repeat.values[repeatlist.indexOf(document['repeat'])];
    type = Type.values[typelist.indexOf(document['type'])];
    allday = document['allday'];
    parti = List<String>.generate(document['participants'].length,
        (i) => document['participants'][i].toString());
  }

  EventModal(day)
      : startDate = DateTime(day.year, day.month, day.day),
        endDate = DateTime(day.year, day.month, day.day),
        startTime =
            TimeOfDay(hour: DateTime.now().hour, minute: DateTime.now().minute),
        endTime = TimeOfDay(
            hour: DateTime.now().hour + 1, minute: DateTime.now().minute),
        startapm = APM.values[DateTime.now().hour < 12 ? 0 : 1],
        endapm = APM.values[DateTime.now().hour + 1 < 12 ? 0 : 1],
        title = '',
        location = '',
        note = '',
        repeat = Repeat.None,
        type = Type.Todo,
        multitype = MultiType.Trip,
        allday = false,
        setup = false;

  EventModal.setup() : setup = true;

  repeatText() => repeatlist[repeat.index];
  typeText() => typelist[type.index];
  multitypeText() => multitypelist[multitype.index];
  get color => typecolor[type.index];

  void startYear(int d) {
    startDate = DateTime(yearlist[d], startDate.month, startDate.day);
    // endUpdate();
  }

  void startMonth(int d) {
    startDate = DateTime(startDate.year, d + 1, startDate.day);
    // endUpdate();
  }

  void startDay(int d) {
    startDate = DateTime(startDate.year, startDate.month, d + 1);
    // endUpdate();
  }

  void startHour(int t) {
    startapm.index == 0
        ? startTime = TimeOfDay(hour: t, minute: startTime.minute)
        : startTime = TimeOfDay(hour: t + 12, minute: startTime.minute);
    // endUpdate();
  }

  void startMinute(int t) {
    startTime = TimeOfDay(hour: startTime.hour, minute: t);
    // endUpdate();
  }

  void startAPM(int a) {
    startapm = APM.values[a];
    startapm.index == 0
        ? startTime =
            TimeOfDay(hour: startTime.hour - 12, minute: startTime.minute)
        : startTime =
            TimeOfDay(hour: startTime.hour + 12, minute: startTime.minute);
    // endUpdate();
  }

  void endYear(int d) {
    endDate = DateTime(yearlist[d], endDate.month, endDate.day);
    // startUpdate();
  }

  void endMonth(int d) {
    endDate = DateTime(endDate.year, d + 1, endDate.day);
    // startUpdate();
  }

  void endDay(int d) {
    endDate = DateTime(endDate.year, endDate.month, d + 1);
    // startUpdate();
  }

  void endHour(int t) => endapm.index == 0
      ? endTime = TimeOfDay(hour: t, minute: endTime.minute)
      : endTime = TimeOfDay(hour: t + 12, minute: endTime.minute);

  void endMinute(int t) {
    endTime = TimeOfDay(hour: endTime.hour, minute: t);
    // startUpdate();
  }

  void endAPM(int a) {
    endapm = APM.values[a];
    endapm.index == 0
        ? endTime = TimeOfDay(hour: endTime.hour - 12, minute: endTime.minute)
        : endTime = TimeOfDay(hour: endTime.hour + 12, minute: endTime.minute);
    // startUpdate();
  }

  checkBefore() {
    List<DateTime> list = getStartandEnd();
    DateTime start = list[0];
    DateTime end = list[1];
    return start.isBefore(end);
  }

  endUpdate() {
    List<DateTime> list = getStartandEnd();
    DateTime start = list[0];
    DateTime end = list[1];
    if (!checkBefore()) {
      end = start.add(Duration(hours: 1));
      endDate = DateTime(end.year, end.month, end.day);
      endTime = TimeOfDay.fromDateTime(end);
      endapm = APM.values[endTime.hour < 12 ? 0 : 1];
    }
  }

  startUpdate() {
    List<DateTime> list = getStartandEnd();
    DateTime start = list[0];
    DateTime end = list[1];
    if (!checkBefore()) {
      start = end.subtract(Duration(hours: 1));
      startDate = DateTime(start.year, start.month, start.day);
      startTime = TimeOfDay.fromDateTime(start);
      startapm = APM.values[startTime.hour < 12 ? 0 : 1];
    }
  }

  List<DateTime> getStartandEnd() {
    DateTime start = startDate
        .add(Duration(hours: startTime.hour, minutes: startTime.minute));
    DateTime end =
        endDate.add(Duration(hours: endTime.hour, minutes: endTime.minute));
    return [start, end];
  }

  // durationUpdate() {
  //   Duration d = end.difference(start);
  //   duration.days = d.inDays;
  //   duration.hours = d.inHours % 24;
  //   duration.minutes = d.inMinutes % 60;
  // }

  // days(i) {
  //   duration.days = i;
  //   endUpdate();
  // }

  // hours(i) {
  //   duration.hours = i;
  //   endUpdate();
  // }

  // minutes(i) {
  //   duration.minutes = i;
  //   endUpdate();
  // }
}

enum APM { AM, PM }

class EventDuration {
  EventDuration({days = 0, hours = 0, minutes = 5})
      : days = days,
        hours = hours,
        minutes = minutes;
  int days, hours, minutes;
}

enum Repeat { None, EveryWeek, EveryMonth, EveryYear }

List<String> repeatlist = ["None", "EveryWeek", "EveryMonth", "EveryYear"];

enum Type { Todo, Birthday, Work, Study, Doctor, Trip, Dating, Friend, Family }

List<String> typelist = [
  "Todo",
  "Birthday",
  "Work",
  "Study",
  "Doctor",
  "Dating",
  "Friend",
  "Family"
];

List<Color> typecolor = [
  SampleColor.grey, // Todo
  SampleColor.lightOrange, // Birthday
  SampleColor.deepBlue, // Work
  SampleColor.lightBlue, // Study
  SampleColor.red, // Doctor
  SampleColor.pink, // Dating
  SampleColor.deepGreen, // Friend
  SampleColor.lightPurple // Family
];

enum MultiType { Trip, Camping, FamilyVisit }

List<String> multitypelist = ["Trip", "Camping", "FamilyVisit"];
List<Color> multitypecolor = [
  SampleColor.coralRed, // Trip
  SampleColor.deepOrange, // Camping
  SampleColor.deepPurple // FamilyVisit
];

class TypePainter extends CustomPainter {
  TypePainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    paint.color = color;
    var center = Offset(-10, size.height / 2);
    canvas.drawCircle(center, 5.0, paint);
  }

  @override
  bool shouldRepaint(TypePainter oldDelegate) => false;

  @override
  bool shouldRebuildSemantics(TypePainter oldDelegate) => false;
}
