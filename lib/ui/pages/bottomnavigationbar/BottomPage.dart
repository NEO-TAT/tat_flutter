import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class BottomPage {
  GlobalKey<NavigatorState> navigatorKey;
  Widget page;

  BottomPage(Widget initPage) {
    navigatorKey = GlobalKey();
    page = _buildNavigator(initPage);
  }

  Widget _buildNavigator(Widget initPage) {
    return Navigator(
        key: navigatorKey,
        onGenerateRoute: (routeSettings) {
          return MaterialPageRoute(
              builder: (context) => initPage);
        });
  }
}


class BottomPageList {
  List<BottomPage> bottomPageList;

  BottomPageList() {
    bottomPageList = List();
  }


  void add(BottomPage page) {
    bottomPageList.add( page );
  }

  List<Widget> get pageList{
    List<Widget> pages = List();
    for(BottomPage bottomPage in bottomPageList){
      pages.add( bottomPage.page );
    }
    return pages;
  }

  Widget getPage(int index){
    return bottomPageList[index].page;
  }

  GlobalKey<NavigatorState> getKey(int index){
    return bottomPageList[index].navigatorKey;
  }
}