import 'package:flutter/material.dart';
import 'package:flutter_app/connector/NTUTConnector.dart';
import 'package:flutter_app/database/DataModel.dart';
import 'package:flutter_app/database/dataformat/UserData.dart';
import 'package:flutter_app/debug/log/Log.dart';
import 'package:flutter_app/ui/other/CustomRoute.dart';
import 'package:flutter_app/ui/pages/login/LoginPage.dart';
import 'package:provider/provider.dart';
import 'pages/airplay_screen.dart';
import 'pages/NewAnnouncementScreen.dart';
import 'pages/home_screen.dart';
import 'pages/pages_screen.dart';

class BottomNavigationWidget extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => BottomNavigationWidgetState();
}

class BottomNavigationWidgetState extends State<BottomNavigationWidget> {
  static final String _className = "BottomNavigationWidgetState";
  final _bottomNavigationColor = Colors.blue;
  int _currentIndex = 0;
  List<Widget> list = List();

  @override
  void initState() {
    list
      ..add(HomeScreen())
      ..add(NewAnnouncementScreen())
      ..add(PagesScreen())
      ..add(AirPlayScreen());
    DataModel.instance.user.load().then((value) {
      Log.e ( _className , value.toString() );
      if (!value) {  //尚未登入
        Navigator.of(context).push( CustomRoute(LoginPage() ));
      }else{
        String account = DataModel.instance.user.account;
        String password = DataModel.instance.user.password;
        NTUTConnector.login(account, password);
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DataModel>(
      builder: (context, dataModel, _) =>
      MaterialApp(
        home: Scaffold(
          body: list[_currentIndex],
          bottomNavigationBar: BottomNavigationBar(
            items: [
              BottomNavigationBarItem(
                  icon: Icon(
                    Icons.announcement,
                    color: _bottomNavigationColor,
                  ),
                  title: Text(
                    'New',
                    style: TextStyle(color: _bottomNavigationColor),
                  )),
              BottomNavigationBarItem(
                  icon: Icon(
                    Icons.email,
                    color: _bottomNavigationColor,
                  ),
                  title: Text(
                    'Email',
                    style: TextStyle(color: _bottomNavigationColor),
                  )),
              BottomNavigationBarItem(
                  icon: Icon(
                    Icons.pages,
                    color: _bottomNavigationColor,
                  ),
                  title: Text(
                    'PAGES',
                    style: TextStyle(color: _bottomNavigationColor),
                  )),
              BottomNavigationBarItem(
                  icon: Icon(
                    Icons.settings,
                    color: _bottomNavigationColor,
                  ),
                  title: Text(
                    'Setting',
                    style: TextStyle(color: _bottomNavigationColor),
                  )),
            ],
            currentIndex: _currentIndex,
            onTap: (int index) {
              setState(() {
                _currentIndex = index;
              });
            },
            type: BottomNavigationBarType.shifting,
          ),
        )
      )
    );
  }
}
