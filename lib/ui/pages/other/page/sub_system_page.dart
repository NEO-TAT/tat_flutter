import 'package:flutter/material.dart';
import 'package:tat/src/connector/ntut_connector.dart';
import 'package:tat/src/model/ntut/ap_tree_json.dart';
import 'package:tat/src/task/ntut/ntut_sub_system_task.dart';
import 'package:tat/src/task/task_flow.dart';
import 'package:tat/src/util/route_utils.dart';

class SubSystemPage extends StatefulWidget {
  final title;
  final arg;

  const SubSystemPage({this.title, this.arg});

  @override
  _SubSystemPageState createState() => _SubSystemPageState();
}

class _SubSystemPageState extends State<SubSystemPage> {
  bool isLoading = true;
  late APTreeJson apTree;

  @override
  void initState() {
    super.initState();
    loadTree(widget.arg);
  }

  void loadTree(String arg) async {
    setState(() {
      isLoading = true;
    });
    final taskFlow = TaskFlow();
    final task = NTUTSubSystemTask(arg);
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
          ? Center(
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
        final ap = apTree.apList[index];
        return InkWell(
          child: Container(
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
              final url = "${NTUTConnector.host}${ap.urlLink}";
              RouteUtils.toWebViewPage(ap.description, url);
            } else {
              RouteUtils.toSubSystemPage(ap.description, ap.apDn);
            }
          },
        );
      },
    );
  }
}
