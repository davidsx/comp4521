// # COMP 4521       #  LAU CHUN HONG        20349438        chlauap
import 'package:calendar/bloc.dart';
import 'package:calendar/screen/calendar_screen.dart';
import 'package:calendar/screen/chat_screen.dart';
import 'package:calendar/screen/user_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Homepage containing the inherited widget

class HomePage extends StatefulWidget {
  HomePage(this.id);
  final String id;

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  SharedPreferences prefs;

  Future getPrefs() async {
    prefs = await SharedPreferences.getInstance();
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    getPrefs();
  }

  @override
  Widget build(BuildContext context) {
    return InheritedCalendar(widget.id, child: IntermidiateWidget());
  }
}

// calling inherited widget to wrap the whole widget tree

class IntermidiateWidget extends StatefulWidget {
  @override
  _IntermidiateWidgetState createState() => _IntermidiateWidgetState();
}

class _IntermidiateWidgetState extends State<IntermidiateWidget> {
  PageController headController;
  PageController bodyController;
  int currentPage;

  @override
  void initState() {
    currentPage = 1;
    headController = PageController(initialPage: 1, viewportFraction: 0.4);
    bodyController = PageController(initialPage: 1);
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: <Widget>[Container()],
        leading: Container(),
        flexibleSpace: SafeArea(
          child: PageView(
            controller: headController,
            onPageChanged: pageAnimateTo,
            children: <Widget>[ 
              Container( // User tab
                width: double.maxFinite,
                child: Center(
                  child: GestureDetector(
                    child: Icon(
                      Icons.person,
                      size: currentPage == 0
                          ? 35.0
                          : 20.0,
                      color: currentPage == 0
                          ? Colors.orange
                          : Colors.grey.withOpacity(0.5),
                    ),
                    onTap: () => pageAnimateTo(0),
                  ),
                ),
              ),
              Container( // Calendar tab
                width: double.maxFinite,
                child: Center(
                  child: GestureDetector(
                    child: Icon(
                      Icons.calendar_today,
                      size: currentPage == 1
                          ? 35.0
                          : 20.0,
                      color: currentPage == 1
                          ? Colors.orange
                          : Colors.grey.withOpacity(0.5),
                    ),
                    onTap: () => pageAnimateTo(1),
                  ),
                ),
              ),
              Container( // Chat tab
                width: double.maxFinite,
                child: Center(
                  child: GestureDetector(
                    child: Icon(
                      Icons.chat_bubble,
                      size: currentPage == 2
                          ? 35.0
                          : 20.0,
                      color: currentPage == 2
                          ? Colors.orange
                          : Colors.grey.withOpacity(0.5),
                    ),
                    onTap: () => pageAnimateTo(2),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
      body: PageView(
        controller: bodyController,
        onPageChanged: pageAnimateTo,
        children: <Widget>[
          UserScreen(),
          CalendarScreen(),
          ChatScreen(),
        ],
      ),
    );
  }

  pageAnimateTo(int page) {
    headController.animateToPage(page,
        duration: Duration(milliseconds: 300), curve: Curves.easeOut);
    bodyController.animateToPage(page,
        duration: Duration(milliseconds: 300), curve: Curves.easeOut);

    setState(() {
      currentPage = page;
    });
  }
}
