// # COMP 4521       #  LAU CHUN HONG        20349438        chlauap
abstract class CalendarEvent{
  CalendarEvent(this.data);
  final data;
}

class Login extends CalendarEvent{
  Login(data):super(data = data);
}

class DayTap extends CalendarEvent{
  DayTap(data):super(data = data);
}

class PageChange extends CalendarEvent{
  PageChange(data):super(data = data);
}

class AddEvent extends CalendarEvent {
  AddEvent(data):super(data = data);
}