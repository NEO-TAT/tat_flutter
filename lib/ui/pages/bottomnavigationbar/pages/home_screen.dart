import 'package:flutter/material.dart';
import 'package:flutter_app/src/taskcontrol/TaskHandler.dart';
import 'package:flutter_app/src/taskcontrol/task/NTUTLoginTask.dart';
import 'package:flutter_app/ui/other/CustomRoute.dart';
import 'package:flutter_app/ui/pages/login/LoginPage.dart';

import '../../../../src/store/Model.dart';
import '../../../../src/store/json/UserDataJson.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreen createState() => _HomeScreen();
}

class _HomeScreen extends State<HomeScreen> {

  @override
  void initState() {
    super.initState();
    Model.instance.init().then( (value) {
      UserDataJson userData = Model.instance.userData;
      if (userData.account.isEmpty || userData.password.isEmpty) {
        //尚未登入
        Navigator.of(context).push(CustomRoute(LoginPage()));
      } else {
        _login();
      }
    });
  }

  void _login() async{
    TaskHandler.instance.startTask( context );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('HOME'),
      ),
    );
  }
}

