import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'auth.dart';
import 'home.dart';
import 'login.dart';

void main() {
  runApp(CrimeMapApp());
}

class CrimeMapApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Crime Map',
      home: SplashScreen(),
      routes: <String, WidgetBuilder>{
        '/home': (context) => Home(),
        '/login': (context) => Login(),
      },
    );
  }
}

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  void splashTimeOut() {
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  void initState() {
    super.initState();
    Timer(Duration(seconds: 3), splashTimeOut);
  }

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
          SizedBox(height: ScreenUtil().setHeight(200))
        ],
      ),
    );
  }
}