import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'auth.dart';

class Login extends StatefulWidget{
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(width: 750, height: 1334, allowFontScaling: true);
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

    return Scaffold(
      backgroundColor: Color(0xFFFFFFFF),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Center(
            child: Container(
              height: ScreenUtil().setHeight(150),
              width: ScreenUtil().setHeight(150),
              child: Image.asset("assets/img/logo1.png"),
            ),
          ),
          SizedBox(height: ScreenUtil().setHeight(35)),
          Text(
            "Crime Alert",
            style: TextStyle(
              color: Color(0xFF000000),
              fontSize: ScreenUtil().setSp(60),
              fontFamily: 'Montserrat',
              fontWeight: FontWeight.w900,
              fontStyle: FontStyle.italic,
              letterSpacing: 1.0,
            ),
          ),
          SizedBox(height: ScreenUtil().setHeight(250)),
          FlatButton(
            onPressed: () {
              authServices.googleSignIn().whenComplete(() {
                Navigator.pushReplacementNamed(context, '/home');
              }).catchError((onError) {
                Flushbar(
                  title:  "Error",
                  message:  "Error occurred, could not sign in with Google. $onError",
                  margin: EdgeInsets.all(8),
                  borderRadius: 8,
                  flushbarStyle: FlushbarStyle.FLOATING,
                  duration:  Duration(seconds: 3),
                )..show(context);
              });
            },
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(30)),
              side: BorderSide(
                color: Color(0xFF33312E),
              ),
            ),
            child: SizedBox(
              width: ScreenUtil().setWidth(350),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Image.asset(
                    'assets/img/google_ico_color.png',
                    scale: 30,
                  ),
                  Text(
                    "Sign in with Google",
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF33312E),
                      fontSize: ScreenUtil().setSp(30),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}