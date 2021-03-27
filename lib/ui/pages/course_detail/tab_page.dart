import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class TabPage {
  GlobalKey<NavigatorState> navigatorKey;
  Widget tab;
  Widget tabPage;

  TabPage(String title, IconData icons, Widget initPage,
      {useNavigatorKey: false}) {
    navigatorKey = GlobalKey();
    tab = Column(
      children: <Widget>[
        Icon(icons),
        AutoSizeText(
          title,
          maxLines: 1,
          minFontSize: 6,
        ),
      ],
    );
    tabPage = (useNavigatorKey)
        ? Navigator(
            key: navigatorKey,
            onGenerateRoute: (routeSettings) {
              return MaterialPageRoute(builder: (context) => initPage);
            })
        : initPage;
  }
}

class TabPageList {
  List<TabPage> tabPageList;

  TabPageList() {
    tabPageList = [];
  }

  void add(TabPage page) {
    tabPageList.add(page);
  }

  List<Widget> get getTabPageList {
    List<Widget> pages = [];
    for (TabPage tabPage in tabPageList) {
      pages.add(tabPage.tabPage);
    }
    return pages;
  }

  List<Widget> getTabList(BuildContext context) {
    List<Widget> pages = [];
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
