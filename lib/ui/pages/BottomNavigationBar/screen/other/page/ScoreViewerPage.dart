import 'package:flutter/material.dart';


class ScoreViewerPage extends StatefulWidget {
  @override
  _ScoreViewerPage createState() => _ScoreViewerPage();
}

class _ScoreViewerPage extends State<ScoreViewerPage> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Setting'),
      ),
      body: Text("score viewer"),
    );
  }


}
