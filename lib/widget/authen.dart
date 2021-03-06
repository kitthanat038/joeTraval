import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:joetravel/utility/My_style.dart';
import 'package:joetravel/utility/normal_dialog.dart';
import 'package:joetravel/widget/register.dart';
import 'package:joetravel/widget/travel.dart';

class Authen extends StatefulWidget {
  @override
  _AuthenState createState() => _AuthenState();
}

class _AuthenState extends State<Authen> {
  // Field

  String user = '', password = '';

  // Method

  Widget singInButton() {
    return RaisedButton(
      color: MyStyle().textcolor,
      child: Text(
        'Sign In',
        style: TextStyle(color: Colors.white),
      ),
      onPressed: () {
        checkAuthen();
      },
    );
  }

  Future<void> checkAuthen() async {
    FirebaseAuth firebaseAuth = FirebaseAuth.instance;
    await firebaseAuth
        .signInWithEmailAndPassword(email: user,password: password)
        .then((respone) {
          MaterialPageRoute materialPageRoute = MaterialPageRoute(builder: (BuildContext buildContext)=>Travel());
          Navigator.of(context).pushAndRemoveUntil(materialPageRoute, (Route<dynamic> route)=>false);
        })
        .catchError((response) {
          String title = response.code;
          String message = response.message;
          normalDialog(context, title, message);
        });
  }

  Widget singUpButton() {
    return OutlineButton(
      child: Text(
        'Sign Up',
        style: TextStyle(color: MyStyle().textcolor),
      ),
      onPressed: () {
        print('You click Sgn Up');

        MaterialPageRoute materialPageRoute =
            MaterialPageRoute(builder: (BuildContext buildContext) {
          return Register();
        });
        Navigator.of(context).push(materialPageRoute);
      },
    );
  }

  Widget showButton() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        singInButton(),
        SizedBox(
          width: 5.0,
        ),
        singUpButton(),
      ],
    );
  }

  Widget userForm() {
    return Container(
      width: 250.0,
      child: TextField(
        onChanged: (String string) {
          user = string.trim();
        },
        keyboardType: TextInputType.emailAddress,
        decoration: InputDecoration(
            enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: MyStyle().textcolor)),
            prefixIcon: Icon(
              Icons.email,
              color: MyStyle().textcolor,
            ),
            hintText: 'User : ',
            hintStyle: TextStyle(color: MyStyle().textcolor)),
      ),
    );
  }

  Widget passwordForm() {
    return Container(
      width: 250.0,
      child: TextField(
        onChanged: (String string) {
          password = string.trim();
        },
        obscureText: true,
        decoration: InputDecoration(
            enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: MyStyle().textcolor)),
            prefixIcon: Icon(
              Icons.lock,
              color: MyStyle().textcolor,
            ),
            hintText: 'Possword : ',
            hintStyle: TextStyle(color: MyStyle().textcolor)),
      ),
    );
  }

  Widget showLoGo() {
    return Container(
      width: 120.0,
      child: Image.asset('images/logo.png'),
    );
  }

  Widget showAppName() {
    return Text(
      'โจ Travel',
      style: MyStyle().h1Text,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
      decoration: BoxDecoration(
        gradient: RadialGradient(
          radius: 2.5,
          colors: <Color>[Colors.white, MyStyle().mainColor],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            showLoGo(),
            showAppName(),
            userForm(),
            passwordForm(),
            SizedBox(
              height: 10.0,
            ),
            showButton(),
          ],
        ),
      ),
    ));
  }
}
