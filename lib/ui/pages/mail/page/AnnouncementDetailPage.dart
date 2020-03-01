import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/debug/log/Log.dart';
import 'package:flutter_app/generated/R.dart';
import 'package:flutter_app/src/file/FileDownload.dart';
import 'package:flutter_app/src/store/json/NewAnnouncementJson.dart';
import 'package:flutter_app/ui/other/ErrorDialog.dart';
import 'package:flutter_app/ui/other/MyToast.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:html/dom.dart' as dom;
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
        child: _showAnnouncementDetail(),
      ),
    );
  }

  Widget _showAnnouncementDetail() {
    return Container(
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Container(
                    color: Colors.white,
                    padding: EdgeInsets.only(left: 10, right: 10, bottom: 10),
                    child: Column(
                      children: <Widget>[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            Expanded(
                              child: Text(
                                widget.data.title,
                                style: TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            Text("from:"),
                            Text(widget.data.sender),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: <Widget>[
                            Text(widget.data.timeString),
                          ],
                        ),
                      ],
                    )),
              ),
            ],
          ),
          Container(
            color: Colors.black,
            padding: EdgeInsets.only(top: 1),
          ),
          Row(
            children: <Widget>[
              Expanded(
                child: _showHtmlWidget(),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _showHtmlWidget() {
    return HtmlWidget(
      widget.data.detail,
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

  Widget _showHtml() {
    return Html(
      data: widget.data.detail,
      //useRichText: false,
      padding: EdgeInsets.all(8.0),
      backgroundColor: Colors.white,
      /*
              defaultTextStyle: TextStyle(fontFamily: 'serif'),
              linkStyle: const TextStyle(
                color: Colors.redAccent,
              ),
               */
      onLinkTap: (url) {
        onUrlTap(url);
      },
      onImageTap: (src) {
        // Display the image in large form.
      },
      //Must have useRichText set to false for this to work.
      customRender: (node, children) {
        if (node is dom.Element) {
          switch (node.localName) {
            case "video":
              break;
            case "custom_tag":
              break;
          }
        }
        return Text("");
      },
      customTextAlign: (dom.Node node) {
        if (node is dom.Element) {
          switch (node.localName) {
            case "p":
              return TextAlign.justify;
          }
        }
        return null;
      },
      customTextStyle: (dom.Node node, TextStyle baseStyle) {
        if (node is dom.Element) {
          switch (node.localName) {
            case "p":
              return baseStyle.merge(TextStyle(height: 2, fontSize: 20));
          }
        }
        return baseStyle;
      },
    );
  }

  _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}
