import 'package:flutter/material.dart';


class OtherScreen extends StatefulWidget {
  @override
  _OtherScreen createState() => _OtherScreen();
}

class _OtherScreen extends State<OtherScreen> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Other'),
      ),
      body: Text("apple"),
    );
  }


}
