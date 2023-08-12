//can you paste here
import 'dart:math';

import 'package:flutter/material.dart';

import '../models/login_details.dart';
import '../providers/auth.dart';
import 'products_overview_screen.dart';
import 'signup.dart';
import 'splashscreen.dart';

class AuthScreen extends StatelessWidget {
  static const routeName = '/auth';

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    return Scaffold(
        // resizeToAvoidBottomInset : false;
        body: Stack(
      children: <Widget>[
        Container(
          decoration: BoxDecoration(
              gradient: LinearGradient(
            colors: [
              Color.fromRGBO(215, 117, 255, 1).withOpacity(0.5),
              Color.fromRGBO(255, 118, 117, 1).withOpacity(0.9),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            stops: [0, 1],
          )),
        ),
        SingleChildScrollView(
          child: Container(
            height: deviceSize.height,
            width: deviceSize.width,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Flexible(
                  child: Container(
                    margin: EdgeInsets.only(bottom: 20.0),
                    padding:
                        EdgeInsets.symmetric(vertical: 8.0, horizontal: 94.0),
                    transform: Matrix4.rotationZ(-8 * pi / 180)
                      ..translate(-10.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Colors.deepOrange.shade900,
                      boxShadow: [
                        BoxShadow(
                          blurRadius: 8,
                          color: Colors.black26,
                          offset: Offset(0, 2),
                        )
                      ],
                    ),
                    child: Text(
                      'MyShop',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 45,
                        fontFamily: 'Anton',
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ),
                ),
                Flexible(
                  flex: deviceSize.width > 600 ? 2 : 1,
                  child: const _AuthCard(),
                )
              ],
            ),
          ),
        )
      ],
    ));
  }
}

class _AuthCard extends StatefulWidget {
  const _AuthCard({Key? key}) : super(key: key);

  @override
  State<_AuthCard> createState() => _AuthCardState();
}

class _AuthCardState extends State<_AuthCard> {
  late String email, password;
  final _formkey = GlobalKey<FormState>();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  Auth authservice = Auth();
  bool _isloading = false;
  // final GlobalKey<FormState> _formKey = GlobalKey();
  signin() async {
    if (_formkey.currentState!.validate()) {
      setState(() {
        _isloading = true;
      });
      await authservice.signinmethod(context, email, password).then((value) {
        if (value != null) {
          setState(() {
            _isloading = false;
          });
          UserLoginSharedPreferences.saveUserLoginStatus(isLoggedIn: true);
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (context) => Splashscreen()));
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      elevation: 8.0,
      child: Container(
        // height: signin() ? 320 : 260,
        // constraints: BoxConstraints(minHeight: signin() ? 320 : 450),
        width: 420,
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formkey,
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                TextFormField(
                  decoration: InputDecoration(labelText: 'E-Mail'),
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  validator: (val) {
                    if (val!.isEmpty) {
                      return 'Enter Email';
                    }
                    if (!RegExp("^[a-zA-Z0-9+_.-]+@[a-zA-Z0-9.-]+.[a-z]")
                        .hasMatch(val)) {
                      return 'Enter a valid Email';
                    }
                    return null;
                  },
                  onChanged: (val) {
                    email = val;
                  },
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Password'),
                  obscureText: true,
                  controller: passwordController,
                  validator: (val) {
                    return val!.isEmpty ? "Enter Password" : null;
                  },
                  onChanged: (val) {
                    password = val;
                  },
                ),
                SizedBox(height: 20.0),
                GestureDetector(
                  onTap: () {
                    signin();
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.teal,
                      borderRadius: BorderRadius.circular(40),
                    ),
                    child: Center(
                      child: Text(
                        'Signin',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 20),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                Text(
                  "Dont have an account?",
                  style: TextStyle(fontSize: 15),
                ),
                SizedBox(
                  width: 4,
                ),
                GestureDetector(
                    onTap: () {
                      Navigator.pushReplacement(context,
                          MaterialPageRoute(builder: (context) => SignUp()));
                    },
                    child: Text(
                      "signup",
                      style: TextStyle(
                          fontSize: 15,
                          color: Colors.red,
                          decoration: TextDecoration.underline,
                          fontWeight: FontWeight.bold),
                    ))
              ],
            ),
          ),
        ),
      ),
    );
  }
}
