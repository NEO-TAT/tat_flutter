import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'database/DataModel.dart';
import 'database/dataformat/UserData.dart';
import 'ui/pages/login/LoginPage.dart';

void main() {
  runApp(ChangeNotifierProvider(
    create: (_) => DataModel(),
    child: MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Navigation Basics',
        home: LoginPage(),
    );
  }
}

