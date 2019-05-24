// # COMP 4521       #  LAU CHUN HONG        20349438        chlauap
import 'dart:async';

import 'package:calendar/event/event_view.dart';
import 'package:calendar/event/event_new.dart';
import 'package:calendar/main.dart';
import 'package:calendar/bloc.dart';
import 'package:calendar/schedule/calendar_component.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CalendarScreen extends StatefulWidget {
  @override
  _CalendarScreenState createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> with RouteAware {
  // List<Event> eventlist;
  final _scaffoldKey = new GlobalKey<ScaffoldState>();
  // OverlayEntry background;
  bool bottomSheetOpen;

  final routeObserver = RouteObserver<PageRoute>();
  final duration = const Duration(milliseconds: 300);

  bool isLoading = false;

  @override
  void initState() {
    bottomSheetOpen = false;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final inherited = InheritedCalendar.of(context);
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      key: _scaffoldKey,
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: <Widget>[
            Flexible(
              flex: 2,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Expanded(
                    child: Column(
                      children: <Widget>[
                        Flexible(
                          flex: 3,
                          child: Align(
                            alignment: Alignment.topLeft,
                            child: Padding(
                              padding: const EdgeInsets.only(
                                  bottom: 2.0, left: 10.0),
                              child: AnimatedCrossFade(
                                duration: Duration(milliseconds: 750),
                                crossFadeState: bottomSheetOpen
                                    ? CrossFadeState.showSecond
                                    : CrossFadeState.showFirst,
                                firstChild: GestureDetector(
                                  onTap: () {
                                    inherited.bloc.returnNow();
                                    inherited.pageAnimatedTo(
                                        getPageIndex(DateTime.now()));
                                  },
                                  child: Text("CALENDAR",
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 35.0)),
                                ),
                                secondChild: Text("ADD EVENT",
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 35.0)),
                              ),
                            ),
                          ),
                        ),
                        Flexible(
                            flex: 2,
                            child: Padding(
                              padding: const EdgeInsets.only(left: 10.0),
                              child: OverflowBox(child: MonthYear()),
                            )),
                      ],
                    ),
                  ),
                  Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        // color: Colors.orange,
                      ),
                      child: IconButton(
                        color: Colors.black,
                        icon: Icon(Icons.add),
                        iconSize: 35.0,
                        onPressed: () {
                          if (!bottomSheetOpen) {
                            setState(() {
                              bottomSheetOpen = !bottomSheetOpen;
                            });
                            new Timer(duration, () {
                              _scaffoldKey.currentState
                                  .showBottomSheet((builder) => NewEvent())
                                  .closed
                                  .whenComplete(() => new Timer(
                                      duration,
                                      () => setState(() =>
                                          bottomSheetOpen = !bottomSheetOpen)));
                            });
                          }
                        },
                      ))
                ],
              ),
            ),
            Flexible(flex: 13, child: Calendar()),
            // Divider(),
            Flexible(flex: 9, child: Event()),
          ],
        ),
      ),
    );
  }
}
