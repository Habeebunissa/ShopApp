import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Myuser {
  String uid;
  Myuser({required this.uid});
}

class Auth with ChangeNotifier {
  // final FirebaseAuth _auth = FirebaseAuth.instance;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  Myuser _userfromfirebase(User? user) {
    return Myuser(uid: user!.uid);
  }

  Future signinmethod(
      BuildContext context, String _email, String _password) async {
    try {
      UserCredential authResult = await _auth.signInWithEmailAndPassword(
          email: _email, password: _password);
      User? firebaseuser = authResult.user;
      return _userfromfirebase(firebaseuser);
    } on FirebaseAuthException catch (e) {
      print(e);
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              content: Text(e.message.toString()),
            );
          });
    }
    notifyListeners();
  }

  Future signupmethod(
      BuildContext context, String _email, String _password) async {
    try {
      UserCredential authResult = await _auth.createUserWithEmailAndPassword(
          email: _email, password: _password);
      User? user = authResult.user;
      return _userfromfirebase(user);
    } on FirebaseAuthException catch (e) {
      print(e);
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              content: Text(e.message.toString()),
            );
          });
    }
    notifyListeners();
  }
}
