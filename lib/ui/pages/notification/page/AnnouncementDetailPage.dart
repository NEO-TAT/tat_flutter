import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/debug/log/Log.dart';
import 'package:flutter_app/src/R.dart';
import 'package:flutter_app/src/file/FileDownload.dart';
import 'package:flutter_app/src/store/json/NewAnnouncementJson.dart';
import 'package:flutter_app/src/util/Constants.dart';
import 'package:flutter_app/ui/other/ErrorDialog.dart';
import 'package:flutter_app/ui/other/MyToast.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:url_launcher/url_launcher.dart';

class AnnouncementDetailPage extends StatefulWidget {
  final NewAnnouncementJson data;

  AnnouncementDetailPage(this.data);

  @override
  _AnnouncementDetailPageState createState() => _AnnouncementDetailPageState();
}

class _AnnouncementDetailPageState extends State<AnnouncementDetailPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.data.courseName),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(0),
        child: _buildAnnouncementDetail(),
      ),
    );
  }

  Widget _buildAnnouncementDetail() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          decoration: BoxDecoration(
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: Theme.of(context).backgroundColor,
              )
            ],
          ),
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  widget.data.title,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(
                  height: 8,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(widget.data.sender),
                    Text(widget.data.timeString),
                  ],
                ),
              ],
            ),
          ),
        ),
        SizedBox(
          height: 16,
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 8),
          child: _showHtmlWidget(),
        ),
      ],
    );
  }

  Widget _showHtmlWidget() {
    return HtmlWidget(
      widget.data.detail,
      hyperlinkColor: Constants.hyperlinkColor,
      onTapUrl: (url) {
        onUrlTap(url);
      },
    );
  }

  void onUrlTap(String url) {
    Log.d(url);
    if (Uri.parse(url).host.contains("ischool")) {
      ErrorDialogParameter parameter = ErrorDialogParameter(
          context: context,
          dialogType: DialogType.INFO,
          title: R.current.fileAttachmentDetected,
          desc: R.current.areYouSureToDownload,
          btnOkText: R.current.download,
          btnCancelText: R.current.cancel,
          btnOkOnPress: () {
            MyToast.show(R.current.downloadWillStart);
            FileDownload.download(context, url, widget.data.courseName);
          });
      ErrorDialog(parameter).show();
    } else {
      _launchURL(url);
    }
  }

  _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}
