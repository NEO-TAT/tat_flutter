// TODO: remove sdk version selector after migrating to null-safety.
// @dart=2.10
import 'package:flutter/material.dart';
import 'package:flutter_app/src/connector/ntut_connector.dart';
import 'package:flutter_app/src/model/ntut/ap_tree_json.dart';
import 'package:flutter_app/src/task/ntut/ntut_sub_system_task.dart';
import 'package:flutter_app/src/task/task_flow.dart';
import 'package:flutter_app/ui/other/route_utils.dart';

class SubSystemPage extends StatefulWidget {
  final String title;
  final String arg;

  const SubSystemPage({Key key, this.title, this.arg}) : super(key: key);

  @override
  State<SubSystemPage> createState() => _SubSystemPageState();
}

class _SubSystemPageState extends State<SubSystemPage> {
  bool isLoading = true;
  APTreeJson apTree;

  @override
  void initState() {
    super.initState();
    loadTree(widget.arg);
  }

  void loadTree(String arg) async {
    setState(() {
      isLoading = true;
    });
    TaskFlow taskFlow = TaskFlow();
    var task = NTUTSubSystemTask(arg);
    taskFlow.addTask(task);
    if (await taskFlow.start()) {
      apTree = task.result;
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : buildTree(),
    );
  }

  Widget buildTree() {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: apTree.apList.length,
      itemBuilder: (BuildContext context, int index) {
        APListJson ap = apTree.apList[index];
        return InkWell(
          child: SizedBox(
            height: 50,
            child: Row(
              children: [
                Expanded(
                  flex: 1,
                  child: Icon((ap.type == 'link') ? Icons.link_outlined : Icons.folder_outlined),
                ),
                Expanded(
                  flex: 8,
                  child: Text(ap.description),
                ),
              ],
            ),
          ),
          onTap: () async {
            if (ap.type == 'link') {
              final urlString = "${NTUTConnector.host}${ap.urlLink}";
              final url = Uri.tryParse(urlString);

              if (url != null) {
                RouteUtils.toWebViewPage(title: ap.description, initialUrl: url);
              } else {
                // TODO: handle exceptions when the url is null. (null means it may caused by the parse process error.)
              }
            } else {
              RouteUtils.toSubSystemPage(ap.description, ap.apDn);
            }
          },
        );
      },
    );
  }
}
