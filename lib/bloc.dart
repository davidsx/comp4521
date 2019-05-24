// # COMP 4521       #  LAU CHUN HONG        20349438        chlauap
import 'dart:async';

import 'package:calendar/main.dart';
import 'package:calendar/schedule/calendar_event.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Inherited Widget

class InheritedCalendar extends InheritedWidget {
  InheritedCalendar(this.userId, {Key key, Widget child})
      : child = child,
        super(key: key);
  final String userId;
  final Widget child;
  final CalendarBloc bloc = CalendarBloc();
  final PageController calendarController =
      PageController(initialPage: getPageIndex(DateTime.now()));
  final PageController monthyearController =
      PageController(initialPage: getPageIndex(DateTime.now()));

  pageAnimatedTo(newPageIndex) {
    calendarController.animateToPage(newPageIndex,
        curve: Curves.easeOut, duration: Duration(milliseconds: 400));
    new Timer(
        Duration(milliseconds: 100),
        () => monthyearController.animateToPage(newPageIndex,
            curve: Curves.easeOut, duration: Duration(milliseconds: 400)));
  }

  headerAnimatedTo(newPageIndex) => new Timer(
      Duration(milliseconds: 100),
      () => monthyearController.animateToPage(newPageIndex,
          curve: Curves.easeOut, duration: Duration(milliseconds: 400)));

  static InheritedCalendar of(BuildContext context) =>
      context.inheritFromWidgetOfExactType(InheritedCalendar)
          as InheritedCalendar;

  @override
  bool updateShouldNotify(InheritedCalendar oldWidget) =>
      oldWidget == this ? false : true;
}

class CalendarBloc {
  SharedPreferences prefs;

  CalendarBloc() {
    initPrefs();
    _calendarEventController.stream.listen(_onCalendarEvent);
    _pageIndexSink.add(getPageIndex(today));
    print("bloc initialized");
  }

  void initPrefs() async {
    selectedDay = today;
    prefs = await SharedPreferences.getInstance();
    String savedDay = prefs.getString('selectedDay');
    if (savedDay != null) {
      selectedDay = DateTime.parse(savedDay);
    }
    _selectedDaySink.add(selectedDay);
  }

  void setPrefs() async {
    await prefs.setString('selectedDay', selectedDay.toString());
  }

  //selectedDay
  DateTime selectedDay;
  DateTime today =
      DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
  Stream<DateTime> get selectedDayStream => _selectedDayController.stream;
  StreamSink<DateTime> get _selectedDaySink => _selectedDayController.sink;
  final _selectedDayController = StreamController<DateTime>.broadcast();
  //pageIndex
  Stream<int> get pageIndex => _pageIndexController.stream;
  StreamSink<int> get _pageIndexSink => _pageIndexController.sink;
  final _pageIndexController = StreamController<int>.broadcast();
  //eventList

  Sink<CalendarEvent> get calendarEvent => _calendarEventController.sink;
  final _calendarEventController = StreamController<CalendarEvent>();

  void returnNow() {
    _selectedDaySink.add(today);
    _pageIndexSink.add(getPageIndex(today));
  }

  _onCalendarEvent(CalendarEvent event) {
    switch (event.runtimeType) {
      case DayTap:
        selectedDay = event.data;
        _selectedDaySink.add(selectedDay);
        setPrefs();
        break;
      case PageChange:
        _pageIndexSink.add(event.data);
        break;
    }
  }

  void dispose() {
    _selectedDayController.close();
    _pageIndexController.close();
    _calendarEventController.close();
    prefs.remove('selectedDay');
    // _currentUserIDController.close();
  }
}
