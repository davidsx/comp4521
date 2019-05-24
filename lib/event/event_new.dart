// # COMP 4521       #  LAU CHUN HONG        20349438        chlauap
import 'package:calendar/event/event_modal.dart';
import 'package:calendar/main.dart';
import 'package:calendar/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NewEvent extends StatefulWidget {
  @override
  _NewEventState createState() => _NewEventState();
}

class _NewEventState extends State<NewEvent> {
  EventModal event;
  OverlayEntry repeatOverlay;
  bool startFlag = false;
  bool endFlag = false;
  bool repeatFlag = false;
  bool typeFlag = false;
  bool isAnimating = false;
  // PageController _controller;
  ScrollPhysics physics;
  FocusNode titleFocus = FocusNode(), locationFocus = FocusNode();
  List<FixedExtentScrollController> controller;
  List<Widget> yearWidget,
      monthWidget,
      dayWidget,
      hourWidget,
      minuteWidget,
      apmWidget;

  GlobalKey<ScaffoldState> errorKey = new GlobalKey<ScaffoldState>();

  @override
  void initState() {
    event = EventModal.setup();
    // _controller = PageController(keepPage: true);
    // physics = AlwaysScrollableScrollPhysics();
    super.initState();
  }

  void initWidgetList() {
    yearWidget = List<Widget>.generate(yearlist.length,
        (int index) => Center(child: Text(yearlist[index].toString())));
    monthWidget = List<Widget>.generate(monthlist3.length,
        (int index) => Center(child: Text(monthlist3[index].toString())));
    dayWidget = List<Widget>.generate(
        DateTime(event.startDate.year, event.startDate.month + 1, 0).day,
        (int index) => Center(child: Text("${index + 1}")));
    hourWidget = List<Widget>.generate(
        12,
        (int index) => index == 0
            ? Center(child: Text("12"))
            : Center(child: Text("$index")));
    minuteWidget = List<Widget>.generate(60,
        (int index) => Center(child: Text(index < 10 ? "0$index" : "$index")));
    apmWidget = [Center(child: Text("AM")), Center(child: Text("PM"))];
  }

  void initController() {
    DateTime date = event.getStartandEnd()[startFlag ? 0 : 1];

    List<int> initItem = [
      yearlist.indexOf(date.year),
      date.month - 1,
      date.day - 1,
      date.hour > 11 ? date.hour - 12 : date.hour,
      date.minute,
      date.hour < 12 ? 0 : 1
    ];

    controller = List<FixedExtentScrollController>.generate(initItem.length,
        (i) => FixedExtentScrollController(initialItem: initItem[i]));
  }

  @override
  Widget build(BuildContext context) {
    if (event.setup == true) {
      event = EventModal(InheritedCalendar.of(context).bloc.selectedDay);
      initWidgetList();
    }
    return Scaffold(
        backgroundColor: Colors.transparent,
        key: errorKey,
        body: SafeArea(
          child: Card(
            margin: const EdgeInsets.only(left: 10.0, right: 10.0, top: 50.0),
            elevation: 12.0,
            child: Container(
              margin: const EdgeInsets.all(5.0),
              // height: MediaQuery.of(context).size.height - 80,
              decoration: new BoxDecoration(
                color: Colors.white,
                borderRadius: new BorderRadius.all(Radius.circular(20.0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  // cancel(),
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 10.0),
                    height: 5.0,
                    width: 30.0,
                    decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(2.5)),
                  ),
                  title(),
                  location(),
                  datetime(),
                  Divider(),
                  Visibility(
                      visible: startFlag || endFlag, child: datetimePicker()),
                  allday(),
                  repeat(),
                  type(),
                  typeFlag ? typePicker() : Container(),
                  note(),
                  add(),
                ],
              ),
            ),
          ),
        ));
  }

  cancel() => Align(
      alignment: Alignment.topRight,
      child: GestureDetector(
          child: Icon(Icons.close,
              color: Theme.of(context).primaryColor.withOpacity(0.8)),
          onTap: () => Navigator.of(context).pop()));
  // title() => ListTile(title: fieldname("Title"), subtitle: titletextfield());
  title() => TextField(
      focusNode: titleFocus,
      textAlign: TextAlign.center,
      onChanged: (title) => setState(() => event.title = title),
      onSubmitted: (title) => setState(() => event.title = title),
      keyboardType: TextInputType.text,
      autofocus: true,
      // textInputAction: TextInputAction.newline,
      controller: TextEditingController(text: event.title),
      maxLength: 30,
      decoration: InputDecoration(
          hintText: titleFocus.hasFocus ? '' : "Title",
          hintStyle: TextStyle(
            color: Theme.of(context).primaryColorDark.withOpacity(1.0),
            fontSize: 18.0,
            fontWeight: FontWeight.w600,
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.all(4.0)));

  location() => TextField(
      focusNode: locationFocus,
      textAlign: TextAlign.center,
      // onTap: ,
      onChanged: (location) => setState(() => event.location = location),
      onSubmitted: (location) => setState(() => event.location = location),
      keyboardType: TextInputType.text,
      maxLength: 30,
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
          hintText: locationFocus.hasFocus ? '' : "Location",
          hintStyle: TextStyle(
            color: Theme.of(context).primaryColorDark.withOpacity(1.0),
            fontSize: 14.0,
            fontWeight: FontWeight.w300,
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.all(4.0)));
  allday() => ListTile(
      // leading: Icon(Icons.label),
      contentPadding: EdgeInsets.only(left: 16.0),
      title: fieldname("All-day"),
      trailing: alldayswitch());
  alldayswitch() => IgnorePointer(
        ignoring: endFlag || startFlag,
        child: Switch(
          onChanged: (allday) {
            setState(() {
              event.allday = allday;
            });
          },
          value: event.allday,
          activeColor: Theme.of(context).primaryColor,
        ),
      );

  datetime() => Container(
        padding: EdgeInsets.symmetric(horizontal: 15.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            Expanded(
              child: GestureDetector(
                  onTap: () {
                    startTrigger();
                    // _selectDate(context);
                    // showDateTimePicker()
                  },
                  child: datetimeBlock(
                      event.startDate, event.startTime, startFlag)),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: Icon(Icons.arrow_forward_ios,
                  color: Colors.black, size: 15.0),
            ),
            Expanded(
              child: GestureDetector(
                  onTap: () => endTrigger(),
                  child: datetimeBlock(event.endDate, event.endTime, endFlag)),
            ),
          ],
        ),
      );
  datetimeBlock(DateTime d, TimeOfDay t, bool flag) => Container(
        padding: EdgeInsets.symmetric(vertical: 6.0, horizontal: 8.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5.0),
          color: flag ? Colors.orange : Colors.transparent,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Text(event.allday ? d.year.toString() : dateParser(d),
                style: TextStyle(
                    color: flag ? Colors.white : Colors.black,
                    fontSize: event.allday ? 14.0 : 16.0,
                    fontWeight: FontWeight.bold)),
            Text(event.allday ? dateParser2(d) : timeParser(t),
                style: TextStyle(
                    color: flag ? Colors.white : Colors.black,
                    fontSize: event.allday ? 22.0 : 20.0,
                    fontWeight: FontWeight.bold)),
          ],
        ),
      );
  datetimePicker() {
    if (controller == null) initController();
    return Container(
      padding: EdgeInsets.all(15.0),
      decoration: new BoxDecoration(
        color: Colors.white,
        shape: BoxShape.rectangle,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          pickers(),
          Container(
            height: 30.0,
            child: FlatButton(
              onPressed: () {
                pickerTrigger();
              },
              child: Text("Confirm"),
            ),
          ),
        ],
      ),
    );
  }

  pickers() {
    return Container(
      height: 100.0,
      child: Row(
        children: <Widget>[
          Expanded(
            flex: 4,
            child: CupertinoPicker(
              useMagnifier: true,
              magnification: 1.3,
              scrollController: controller[0],
              itemExtent: 32.0,
              backgroundColor: Colors.white,
              onSelectedItemChanged: (int i) => setState(() {
                    if (!isAnimating)
                      startFlag ? event.startYear(i) : event.endYear(i);
                  }),
              children: yearWidget,
            ),
          ),
          VerticalDivider(width: 1.0),
          Expanded(
            flex: 3,
            child: CupertinoPicker(
              looping: true,
              useMagnifier: true,
              magnification: 1.3,
              scrollController: controller[1],
              itemExtent: 32.0,
              backgroundColor: Colors.white,
              onSelectedItemChanged: (int i) => setState(() {
                    if (!isAnimating)
                      startFlag ? event.startMonth(i) : event.endMonth(i);
                  }),
              children: monthWidget,
            ),
          ),
          VerticalDivider(width: 1.0),
          Expanded(
            flex: 2,
            child: CupertinoPicker(
              looping: true,
              useMagnifier: true,
              magnification: 1.3,
              scrollController: controller[2],
              itemExtent: 32.0,
              backgroundColor: Colors.white,
              onSelectedItemChanged: (int i) => setState(() {
                    if (!isAnimating)
                      startFlag ? event.startDay(i) : event.endDay(i);
                  }),
              children: dayWidget,
            ),
          ),
          event.allday ? Container() : VerticalDivider(width: 1.0),
          event.allday
              ? Container()
              : Expanded(
                  flex: 2,
                  child: CupertinoPicker(
                    looping: true,
                    useMagnifier: true,
                    magnification: 1.3,
                    scrollController: controller[3],
                    itemExtent: 32.0,
                    backgroundColor: Colors.white,
                    onSelectedItemChanged: (int i) => setState(() {
                          if (!isAnimating)
                            startFlag ? event.startHour(i) : event.endHour(i);
                        }),
                    children: hourWidget,
                  ),
                ),
          event.allday ? Container() : VerticalDivider(width: 1.0),
          event.allday
              ? Container()
              : Expanded(
                  flex: 2,
                  child: CupertinoPicker(
                    looping: true,
                    useMagnifier: true,
                    magnification: 1.3,
                    scrollController: controller[4],
                    itemExtent: 32.0,
                    backgroundColor: Colors.white,
                    onSelectedItemChanged: (int i) => setState(() {
                          if (!isAnimating)
                            startFlag
                                ? event.startMinute(i)
                                : event.endMinute(i);
                        }),
                    children: minuteWidget,
                  ),
                ),
          event.allday ? Container() : VerticalDivider(width: 1.0),
          event.allday
              ? Container()
              : Expanded(
                  flex: 2,
                  child: CupertinoPicker(
                    useMagnifier: true,
                    magnification: 1.3,
                    scrollController: controller[5],
                    itemExtent: 32.0,
                    backgroundColor: Colors.white,
                    onSelectedItemChanged: (int i) => setState(() {
                          if (!isAnimating)
                            startFlag ? event.startAPM(i) : event.endAPM(i);
                        }),
                    children: apmWidget,
                  ),
                ),
        ],
      ),
    );
  }

  repeat() => ListTile(
      title: fieldname("Repeat"),
      trailing: GestureDetector(
        child: fieldvalue(event.repeatText()),
        onTap: () {
          if (!repeatFlag) {
            repeatOverlay = getRepeatOverlay();
            Overlay.of(context).insert(repeatOverlay);
            repeatFlag = true;
          }
        },
      ));
  getRepeatOverlay() {
    RenderBox renderBox = context.findRenderObject();
    var offset = renderBox.localToGlobal(Offset.zero);
    return OverlayEntry(
        builder: (context) => Positioned(
            right: 16.0,
            top: offset.dy + 375.0,
            width: MediaQuery.of(context).size.width / 3,
            // height: 400.0,
            child: Card(
                elevation: 4.0,
                child: ListView.builder(
                    padding: EdgeInsets.zero,
                    shrinkWrap: true,
                    itemCount: repeatlist.length,
                    itemBuilder: (context, i) => GestureDetector(
                        child: Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text(repeatlist[i],
                                textAlign: TextAlign.left,
                                style: TextStyle(fontSize: 20.0))),
                        onTap: () {
                          setState(() {
                            event.repeat = Repeat.values[i];
                          });
                          repeatOverlay.remove();
                          repeatFlag = false;
                        })))));
  }

  type() => ListTile(
      title: fieldname("Calendar"),
      trailing: GestureDetector(
          onTap: () => setState(() => typeFlag = !typeFlag),
          child: CustomPaint(
            painter: TypePainter(typecolor[event.type.index]),
            child: fieldvalue(event.typeText()),
          )));
  typePicker() => Container(
      margin: EdgeInsets.only(bottom: 16.0),
      height: 45.0,
      child: CupertinoScrollbar(
          child: ListView.builder(
              padding: EdgeInsets.only(bottom: 16.0),
              scrollDirection: Axis.horizontal,
              itemCount: typelist.length,
              itemBuilder: (context, i) => GestureDetector(
                  onTap: () => setState(() {
                        typeFlag = !typeFlag;
                        event.type = Type.values[i];
                      }),
                  child: Container(
                      margin: EdgeInsets.symmetric(horizontal: 10.0),
                      width: 100.0,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20.0),
                        color: typecolor[i],
                      ),
                      child: Align(
                        alignment: Alignment.center,
                        child: Text(typelist[i],
                            style: TextStyle(
                              fontSize: 20.0,
                              color: SampleColor.white,
                            )),
                      ))))));
  note() {
    return ListTile(
      title: fieldname("Note"),
      subtitle: TextField(
          // focusNode: titleFocus,
          textAlign: TextAlign.left,
          onChanged: (note) => setState(() => event.note = note),
          onSubmitted: (note) => setState(() => event.note = note),
          keyboardType: TextInputType.text,
          // autofocus: true,
          // textInputAction: TextInputAction.newline,
          controller: TextEditingController(text: event.note),
          maxLength: null,
          maxLines: null,
          decoration: InputDecoration(
              border: InputBorder.none, contentPadding: EdgeInsets.all(4.0))),
    );
  }

  add() => Expanded(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 0.0),
          child: Align(
            alignment: Alignment.bottomCenter,
            child: IconButton(
              icon: Icon(Icons.add_circle_outline),
              iconSize: 70.0,
              color: Theme.of(context).primaryColor,
              onPressed: () {
                validation();
              },
            ),
          ),
        ),
      );
  validation() {
    if (event.title == '' || event.title == null) {
      snackBar(errorlist[0]);
    } else if (event.getStartandEnd()[0].isAfter(event.getStartandEnd()[1])) {
      snackBar(errorlist[1]);
    } else {
      addEvent();
    }
  }

  List<String> errorlist = [
    "Title cannot be empty",
    "Start date cannot be later than end date"
  ];

  snackBar(error) => errorKey.currentState.showSnackBar(
      SnackBar(content: Text(error), duration: Duration(seconds: 3)));

  addEvent() async {
    Navigator.of(context).pop();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String userId = prefs.getString('id');

    Firestore.instance.collection('events').add({
      'host': userId,
      'participants': [userId],
      'start': event.startDate
          .add(Duration(
              hours: event.startTime.hour, minutes: event.startTime.minute))
          .millisecondsSinceEpoch,
      'startDate': event.startDate.millisecondsSinceEpoch,
      'end': event.endDate
          .add(Duration(
              hours: event.endTime.hour, minutes: event.endTime.minute))
          .millisecondsSinceEpoch,
      'endDate': event.endDate.millisecondsSinceEpoch,
      'title': event.title,
      'location': event.location,
      'allday': event.allday,
      'type': event.typeText(),
      'note': event.note,
    });

    // switch (event.repeat) {
    //   case Repeat.None:
    //     break;
    //   case Repeat.EveryWeek:
    //     break;
    //   case Repeat.EveryMonth:
    //     break;
    //   case Repeat.EveryYear:
    //     break;
    // }
  }

  // helper function
  fieldname(String name) => Text(name,
      style: TextStyle(
          color: Theme.of(context).primaryColorDark.withOpacity(1.0),
          fontSize: 18.0,
          fontWeight: FontWeight.w600));
  hinttextStyle() => TextStyle(
      color: Theme.of(context).primaryColorDark.withOpacity(1.0),
      fontSize: 18.0,
      fontWeight: FontWeight.w600);
  fieldvalue(String value) =>
      Text(value, textAlign: TextAlign.right, style: TextStyle(fontSize: 20.0));

  startTrigger() {
    setState(() {
      if (!endFlag && !startFlag) {
        startFlag = true;
        initController();
      }
      startFlag = true;
      endFlag = false;
      event.startUpdate();
    });
    pickerAnimate();
  }

  endTrigger() {
    setState(() {
      if (!endFlag && !startFlag) {
        startFlag = false;
        initController();
      }
      startFlag = false;
      endFlag = true;
      event.endUpdate();
    });
    pickerAnimate();
  }

  pickerTrigger() => setState(() {
        startFlag = false;
        endFlag = false;
        // controller = null;
      });
  pickerAnimate() {
    DateTime date = event.getStartandEnd()[startFlag ? 0 : 1];

    List<int> initItem = [
      yearlist.indexOf(date.year),
      date.month - 1,
      date.day - 1,
      date.hour > 11 ? date.hour - 12 : date.hour,
      date.minute,
      date.hour < 12 ? 0 : 1
    ];

    setState(() {
      isAnimating = true;
    });

    for (var i = 0; i < controller.length; i++) {
      controller[i].jumpToItem(initItem[i]);
    }

    setState(() {
      isAnimating = false;
    });
  }
}
