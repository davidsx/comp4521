// # COMP 4521       #  LAU CHUN HONG        20349438        chlauap
import 'package:calendar/chat/chat_invitation.dart';
import 'package:calendar/chat/chat_message.dart';
import 'package:calendar/chat/chat_modal.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChatRoom extends StatefulWidget {
  final UserModal peer;
  ChatRoom(this.peer);
  @override
  _ChatRoomState createState() => _ChatRoomState();
}

class _ChatRoomState extends State<ChatRoom> {
  // List<String> messagelist;
  TextEditingController msgController;
  ScrollController scrollController;
  FocusNode focusNode = FocusNode();

  String chatId;
  String id, peerId;
  SharedPreferences prefs;

  @override
  void initState() {
    super.initState();
    msgController = TextEditingController(text: '');
    scrollController = ScrollController();
    // messagelist = List<String>();
    readLocal();
  }

  readLocal() async {
    prefs = await SharedPreferences.getInstance();
    peerId = widget.peer.id;
    id = prefs.getString('id') ?? '';
    if (id.hashCode <= peerId.hashCode) {
      chatId = '$id-$peerId';
    } else {
      chatId = '$peerId-$id';
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(
          color: Colors.orange,
        ),
        title: Text(widget.peer.username),
        actions: <Widget>[
          FlatButton(
            highlightColor: Colors.transparent,
            child: Text(
              "EDIT",
              style: TextStyle(
                  color: Colors.orange,
                  fontWeight: FontWeight.w900,
                  fontSize: 18.0),
            ),
            onPressed: () {},
          )
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
          stream: Firestore.instance
              .collection("chat_room")
              .document(chatId)
              .collection(chatId)
              .orderBy("timestamp", descending: false)
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData)
              return Container(color: Colors.white);
            else {
              final List<DocumentSnapshot> documents = snapshot.data.documents;
              List<MsgModal> messages = List<MsgModal>.generate(
                  documents.length,
                  (i) => MsgModal.fromFirestore(documents[i]));
                  // print(messages[0].)
              return Container(
                color: Colors.white,
                child: CupertinoScrollbar(
                  child: ListView.builder(
                    reverse: false,
                    controller: scrollController,
                    itemCount: snapshot.data.documents.length,
                    itemBuilder: (context, i) {
                      bool isOwnMessage = false;
                      if (messages[i].idFrom == id) {
                        isOwnMessage = true;
                      } else {
                        Firestore.instance
                            .collection("chat_room")
                            .document(chatId)
                            .collection(chatId)
                            .document(messages[i].id)
                            .updateData({'isRead': true});
                      }
                      switch (messages[i].type) {
                        case 0:
                          return Message(messages[i], isOwnMessage);
                          break;
                        case 1:
                          return Invitation(messages[i], isOwnMessage);
                      }
                    },
                  ),
                ),
              );
            }
          }),
      bottomNavigationBar: BottomAppBar(
        color: Theme.of(context).primaryColor,
        elevation: 5.0,
        child: SafeArea(
          child: Row(
            children: <Widget>[
              Expanded(
                child: TextField(
                  focusNode: focusNode,
                  controller: msgController,
                  keyboardType: TextInputType.text,
                  textInputAction: TextInputAction.newline,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Message',
                    contentPadding: EdgeInsets.all(15.0),
                  ),
                  onSubmitted: (msg) => _handleSubmit(msg),
                ),
              ),
              IconButton(
                  icon: Icon(Icons.send),
                  onPressed: () {
                    _handleSubmit(msgController.text);
                  }),
            ],
          ),
        ),
      ),
    );
  }

  void _handleSubmit(String msg) {
    // type: 0 = text, 1 = invitation, 2 = image
    if (msg.trim() != '') {
      msgController.clear();

      int now = DateTime.now().millisecondsSinceEpoch;

      Firestore.instance
          .collection("chat_room")
          .document(chatId)
          .collection(chatId)
          .add({
        'idFrom': id,
        'idTo': peerId,
        'timestamp': now,
        'content': msg,
        'type': 0,
        'isRead': false,
      }).then((val) {
        print("message add");
      }).catchError((err) {
        print(err);
      });

      Firestore.instance.collection("chat_room").document(chatId).setData({
        'users': [id, peerId],
        'last_updated': now
      }).then((val) {
        print("message updated");
      }).catchError((err) {
        print(err);
      });

      scrollController.animateTo(0.0,
          duration: Duration(milliseconds: 300), curve: Curves.easeOut);
    }
  }
}
