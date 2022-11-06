// ignore_for_file: import_of_legacy_library_into_null_safe

import 'package:flutter/material.dart';
import 'package:flutter_app/src/config/app_colors.dart';
import 'package:flutter_app/src/config/app_link.dart';
import 'package:flutter_app/src/connector/core/connector.dart';
import 'package:flutter_app/src/connector/core/connector_parameter.dart';
import 'package:flutter_app/src/r.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Text(R.current.PrivacyPolicy),
        ),
        body: FutureBuilder<String>(
          future: Connector.getDataByGet(ConnectorParameter(AppLink.privacyPolicyUrlString)),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return Markdown(
                selectable: true,
                data: snapshot.data ?? '',
              );
            } else if (snapshot.hasError) {
              return const Center(
                child: Icon(Icons.error),
              );
            }
            return const Center(
              child: SpinKitDoubleBounce(
                color: AppColors.mainColor,
              ),
            );
          },
        ),
      );
}
