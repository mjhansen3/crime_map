import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'auth.dart';
import 'map.dart';
import 'newMap.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  DateTime currentBackPressTime = DateTime.now();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(width: 750, height: 1334, allowFontScaling: true);

    return Scaffold(
      backgroundColor: Color(0xFFEFF0F1),
      appBar: AppBar(
        title: Text('Crime Map'),
        centerTitle: true,
        backgroundColor: Color(0xFFE85D09),
        actions: <Widget>[
          FlatButton(
            onPressed: () async {
              authServices.signOutUser();
              Navigator.popAndPushNamed(context, '/login');
            },
            child: Icon(
              Icons.power_settings_new,
              color: Colors.white,
            ),
          )
        ],
      ),
      body: WillPopScope(
          child: NewMap(),
          onWillPop: onWillPop,
      ),
    );
  }

  Future<bool> onWillPop() {
    DateTime now = DateTime.now();
    if (now.difference(currentBackPressTime) > Duration(seconds: 3)) {
      currentBackPressTime = now;
      FlutterToast.showToast(
          msg: "Press back button again to exit app!",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.black54,
          textColor: Colors.white,
          fontSize: ScreenUtil().setSp(20),
      );
      return Future.value(false);
    }
    return Future.value(true);
  }
}