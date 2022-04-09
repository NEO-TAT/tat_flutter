import 'package:flutter/material.dart';
import 'package:flutter_app/src/R.dart';
import 'package:flutter_app/src/config/AppColors.dart';
import 'package:flutter_app/src/config/AppLink.dart';
import 'package:flutter_app/src/connector/core/Connector.dart';
import 'package:flutter_app/src/connector/core/ConnectorParameter.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class PrivacyPolicyPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(R.current.PrivacyPolicy),
      ),
      body: FutureBuilder<String>(
        future: Connector.getDataByGet(ConnectorParameter(AppLink.privacyPolicyUrl)),
        builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
          if (snapshot.hasData) {
            return Markdown(
              selectable: true,
              data: snapshot.data,
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Icon(Icons.error),
            );
          }
          return Center(
            child: SpinKitDoubleBounce(
              color: AppColors.mainColor,
            ),
          );
        },
      ),
    );
  }
}
