import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_app/debug/log/Log.dart';
import 'package:flutter_app/ui/other/ExpandableText.dart';
import 'package:flutter_app/ui/other/MyToast.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

class DebugPage extends StatefulWidget {
  DebugPage();

  @override
  _DebugPageState createState() => _DebugPageState();
}

class _DebugPageState extends State<DebugPage>
    with SingleTickerProviderStateMixin {
  TabController _tabController;
  PageController _pageController = PageController();
  int _currentIndex = 0;

  @override
  void initState() {
    _tabController = TabController(vsync: this, length: 2);
    super.initState();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Debug Page"),
        actions: <Widget>[
          FlatButton(
            onPressed: () {
              setState(() {
                Log.debugLog = List();
                Log.errorLog = List();
              });
            },
            child: new Text("Clear All"),
          ),
        ],
        bottom: TabBar(
          indicatorPadding: EdgeInsets.all(0),
          labelPadding: EdgeInsets.all(0),
          isScrollable: true,
          controller: _tabController,
          tabs: [
            Container(
              width: MediaQuery.of(context).size.width / 2,
              child: Tab(text: "Debug"),
            ),
            Container(
              width: MediaQuery.of(context).size.width / 2,
              child: Tab(text: "Error"),
            ),
          ],
          onTap: (index) {
            _pageController.jumpToPage(index);
            _currentIndex = index;
          },
        ),
      ),
      body: PageView(
        //控制滑動
        controller: _pageController,
        children: [
          buildLog(Log.debugLog.reversed.toList()),
          buildLog(Log.errorLog.reversed.toList())
        ],
        onPageChanged: (index) {
          _tabController.animateTo(index); //與上面tab同步
          _currentIndex = index;
        },
      ),
    );
  }

  Widget buildLog(List<String> logList) {
    return ListView.separated(
      itemCount: logList.length,
      itemBuilder: (BuildContext context, int index) {
        return AnimationConfiguration.staggeredList(
          position: index,
          duration: const Duration(milliseconds: 375),
          child: GestureDetector(
            behavior: HitTestBehavior.opaque, //讓透明部分有反應
            child: Container(
                padding:
                    EdgeInsets.only(left: 20, right: 20, top: 10, bottom: 10),
                child: ExpandableText(
                  text: logList[index],
                  maxLines: 3,
                )),
            onLongPress: () {
              Clipboard.setData(ClipboardData(text: logList[index]));
              MyToast.show("Copy");
            },
          ),
        );
      },
      separatorBuilder: (BuildContext context, int index) {
        return Divider(
            height: 3.0, color: Theme.of(context).textSelectionColor);
      },
    );
  }
}
