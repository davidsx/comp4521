// # COMP 4521       #  LAU CHUN HONG        20349438        chlauap
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MsgModal {
  String id;
  String content, idFrom, idTo;
  DateTime time;
  int type;
  bool isRead, isReacted;

  MsgModal.fromFirestore(DocumentSnapshot document) {
    id = document.documentID;
    time = DateTime.fromMillisecondsSinceEpoch(document['timestamp']);
    content = document['content'];
    idFrom = document['idFrom'];
    idTo = document['idTo'];
    type = document['type'];
    isRead = document['isRead'];
    isReacted = document['isReacted'] ?? false;
  }
}

class UserModal {
  String id, email, username, photo;

  UserModal.setUp() {
    id = '';
    email = '';
    username = '';
    photo = '';
  }

  UserModal.fromFirestore(DocumentSnapshot document) {
    id = document['id'];
    email = document['email'];
    username = document['username'];
    photo = document['photoUrl'];
  }

  UserModal.fromPrefs(SharedPreferences prefs) {
    // Write data to local
    id = prefs.getString('id');
    username = prefs.getString('username');
    email = prefs.getString('email');
    //  prefs.getString('phone');
    photo = prefs.getString('photoUrl') == null ? '' : prefs.getString('photoUrl');
  }
}
