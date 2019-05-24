// # COMP 4521       #  LAU CHUN HONG        20349438        chlauap
import 'package:calendar/chat/chat_modal.dart';
import 'package:flutter/material.dart';

class Message extends StatefulWidget {
  final MsgModal msg;
  final bool isOwnMessage;
  Message(this.msg, this.isOwnMessage);

  @override
  _MessageState createState() => _MessageState();

  static timestamp() {
    int hour = DateTime.now().hour;
    String hourstr = (hour > 11 ? hour - 11 : hour).toString();
    int minute = DateTime.now().minute;
    String minutestr =
        (minute < 10 ? '0' + minute.toString() : minute.toString());
    String apm = hour > 11 ? 'PM' : 'AM';
    return hourstr + ':' + minutestr + ' ' + apm;
  }
}

class _MessageState extends State<Message> {
  MsgModal msg;
  bool isOwnMessage;

  @override
  void initState() {
    msg = widget.msg;
    isOwnMessage = widget.isOwnMessage;
    super.initState();
  }

  @override
  void didUpdateWidget(Message oldWidget) {
    if (oldWidget.msg != msg) super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    String time = Message.timestamp();
    final needlist = _calcLastLineEnd(msg.content);
    bool needPadding = needlist[0], needNextline = needlist[1];

    return Row(
      mainAxisAlignment:
          isOwnMessage ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: <Widget>[
        Container(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width / 5 * 3,
            minHeight: 30.0,
            minWidth: 80.0,
          ),
          margin: const EdgeInsets.all(4.0),
          padding: const EdgeInsets.all(8.0),
          decoration: BoxDecoration(
              // boxShadow: [BoxShadow()],
              color: isOwnMessage
                  ? Colors.greenAccent.shade100
                  : Colors.grey.shade300,
              borderRadius: BorderRadius.circular(10.0)),
          child: Stack(
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(
                  right: needPadding ? 60.0 : 0.0,
                  bottom: needNextline ? 17.0 : 0.0,
                ),
                child: Text.rich(TextSpan(text: msg.content)),
              ),
              Positioned(
                bottom: 0.0,
                right: 0.0,
                child: Row(
                  children: <Widget>[
                    Text(time,
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 10.0,
                        )),
                    isOwnMessage
                        ? Icon(
                            Icons.done_all,
                            size: 12.0,
                            color: msg.isRead ? Colors.blue : Colors.black38,
                          )
                        : Container()
                  ],
                ),
              )
            ],
          ),
        ),
      ],
    );
  }

  List<bool> _calcLastLineEnd(String msg) {
    // self-defined constraint
    final constraints = BoxConstraints(
      maxWidth: 800.0, // maxwidth calculated
      minHeight: 30.0,
      minWidth: 80.0,
    );
    final richTextWidget =
        Text.rich(TextSpan(text: msg)).build(context) as RichText;
    final renderObject = richTextWidget.createRenderObject(context);
    renderObject.layout(constraints);
    final boxes = renderObject.getBoxesForSelection(TextSelection(
        baseOffset: 0, extentOffset: TextSpan(text: msg).toPlainText().length));
    bool needPadding = false, needNextline = false;
    double boundary = 620;
    if (boxes.length < 2 && boxes.last.right < boundary) needPadding = true;
    if (boxes.length < 2 && boxes.last.right > boundary) needNextline = true;
    if (boxes.length > 1 && boxes.last.right > boundary) needNextline = true;
    return [needPadding, needNextline];
  }
}
