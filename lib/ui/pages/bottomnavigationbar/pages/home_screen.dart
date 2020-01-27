import 'package:flutter/material.dart';
import 'package:flutter_app/src/store/DataModel.dart';
import 'package:flutter_app/src/store/dataformat/UserData.dart';
import 'package:flutter_app/src/taskcontrol/TaskHandler.dart';
import 'package:flutter_app/src/taskcontrol/task/NTUTLoginTask.dart';
import 'package:flutter_app/ui/other/CustomRoute.dart';
import 'package:flutter_app/ui/pages/login/LoginPage.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreen createState() => _HomeScreen();
}

class _HomeScreen extends State<HomeScreen> {

  @override
  void initState() {
    super.initState();
    DataModel.instance.init().then( (value) {
      UserData user = DataModel.instance.user;
      if (user.account.isEmpty || user.password.isEmpty) {
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

