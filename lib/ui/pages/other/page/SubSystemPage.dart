import 'package:flutter/material.dart';
import 'package:flutter_app/src/model/ntut/APTreeJson.dart';
import 'package:flutter_app/src/task/TaskFlow.dart';
import 'package:flutter_app/src/task/ntut/NTUTSubSystemTask.dart';
import 'package:flutter_app/ui/other/RouteUtils.dart';
class SubSystemPage extends StatefulWidget {
  @override
  _SubSystemPageState createState() => _SubSystemPageState();
}

class _SubSystemPageState extends State<SubSystemPage> {
  bool isLoading = true;
  APTreeJson apTree;

  @override
  void initState() {
    super.initState();
    loadTree(null);
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

  Future<bool> _onWillPop() async {
    if (apTree != null && apTree.parentDn.isNotEmpty) {
      loadTree(apTree.parentDn);
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("系統"),
      ),
      body: WillPopScope(
        onWillPop: _onWillPop,
        child: isLoading
            ? Center(child: CircularProgressIndicator())
            : buildTree(),
      ),
    );
  }

  Widget buildTree() {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: apTree.apList.length,
      itemBuilder: (BuildContext context, int index) {
        APListJson ap = apTree.apList[index];
        return InkWell(
          child: Container(
            height: 50,
            child: Row(
              children: [
                Expanded(
                  flex: 1,
                  child: Icon((ap.type == 'link')
                      ? Icons.link_outlined
                      : Icons.folder_outlined),
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
              String url = "https://app.ntut.edu.tw/" + ap.urlLink;
              RouteUtils.toWebViewPage(ap.description, url);
            } else {
              loadTree(ap.apDn);
            }
          },
        );
      },
    );
  }
}
