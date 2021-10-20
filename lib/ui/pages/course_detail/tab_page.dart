import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class TabPage {
  late final GlobalKey<NavigatorState> navigatorKey;
  late Widget tab;
  late Widget tabPage;

  TabPage(String title, IconData icons, Widget initPage,
      {useNavigatorKey: false}) {
    navigatorKey = GlobalKey();
    tab = Column(
      children: [
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
  List<TabPage> tabPageList = [];

  TabPageList();

  void add(TabPage page) {
    tabPageList.add(page);
  }

  List<Widget> get getTabPageList {
    final List<Widget> pages = [];
    for (final tabPage in tabPageList) {
      pages.add(tabPage.tabPage);
    }
    return pages;
  }

  List<Widget> getTabList(BuildContext context) {
    final List<Widget> pages = [];
    final width = MediaQuery.of(context).size.width / this.length;
    for (final tabPage in tabPageList) {
      final tabNew = Container(
        width: width,
        child: tabPage.tab,
      );
      pages.add(tabNew);
    }
    return pages;
  }

  Widget getPage(int index) => tabPageList[index].tabPage;

  GlobalKey<NavigatorState> getKey(int index) =>
      tabPageList[index].navigatorKey;

  int get length => tabPageList.length;
}
