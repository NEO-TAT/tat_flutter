import 'package:flutter/material.dart';
import 'package:flutter_app/src/R.dart';
import 'package:flutter_app/src/config/app_colors.dart';
import 'package:flutter_app/src/config/app_link.dart';
import 'package:flutter_app/src/connector/core/connector.dart';
import 'package:flutter_app/src/connector/core/connector_parameter.dart';
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
        future: Connector.getDataByGet(
            ConnectorParameter(AppLink.privacyPolicyUrl)),
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
