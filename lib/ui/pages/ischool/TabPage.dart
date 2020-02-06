import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/debug/log/Log.dart';

class TabPage {
  GlobalKey<NavigatorState> navigatorKey;
  Widget tab;
  Widget tabPage;

  TabPage(String title, IconData icons, Widget initPage) {
    navigatorKey = GlobalKey();
    tab = Column(
      children: <Widget>[
        Icon(icons),
        Text(title),
      ],
    );
    tabPage = Navigator(
        key: navigatorKey,
        onGenerateRoute: (routeSettings) {
          return MaterialPageRoute(
              builder: (context) => initPage);
        });
  }
}

class TabPageList {
  List<TabPage> tabPageList;

  TabPageList() {
    tabPageList = List();
  }

  void add(TabPage page) {
    tabPageList.add(page);
  }

  List<Widget> get getTabPageList {
    List<Widget> pages = List();
    for (TabPage tabPage in tabPageList) {
      pages.add(tabPage.tabPage);
    }
    return pages;
  }

  List<Widget> getTabList(BuildContext context) {
    List<Widget> pages = List();
    double width = MediaQuery.of(context).size.width / this.length;
    for (TabPage tabPage in tabPageList) {
      Widget tabNew = Container(
        width: width,
        child: tabPage.tab,
      );
      pages.add(tabNew);
    }
    return pages;
  }

  Widget getPage(int index) {
    return tabPageList[index].tabPage;
  }

  GlobalKey<NavigatorState> getKey(int index) {
    return tabPageList[index].navigatorKey;
  }

  int get length {
    return tabPageList.length;
  }
}
