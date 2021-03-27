import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_app/src/R.dart';
import 'package:flutter_app/src/store/model.dart';
import 'package:flutter_app/ui/other/listview_animator.dart';
import 'package:get/get.dart';
import 'package:pretty_json/pretty_json.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StoreEditPage extends StatefulWidget {
  StoreEditPage();

  @override
  _StoreEditPageState createState() => _StoreEditPageState();
}

class _StoreEditPageState extends State<StoreEditPage> {
  SharedPreferences pref;
  List<String> keyList;

  @override
  void initState() {
    super.initState();
  }

  Future<List<String>> initPref() async {
    pref = await SharedPreferences.getInstance();
    return pref.getKeys().toList();
  }

  @override
  void dispose() {
    Model.instance.getInstance();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Edit Page"),
      ),
      body: FutureBuilder<List<String>>(
        future: initPref(),
        builder: (BuildContext context, AsyncSnapshot<List<String>> snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else {
            keyList = keyList ?? snapshot.data;
            return ListView.separated(
              itemCount: keyList.length,
              itemBuilder: (context, index) {
                String key = keyList[index];
                final TextEditingController controller =
                    TextEditingController();
                try {
                  controller.text = prettyJson(
                      json.decode(pref.get(key).toString()),
                      indent: 2);
                } catch (e) {
                  controller.text = pref.get(key).toString();
                }
                return Container(
                  padding: EdgeInsets.only(top: 5, left: 20, right: 20),
                  child: WidgetAnimator(
                    Container(
                      height: 50,
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(key),
                          ),
                          IconButton(
                              icon: Icon(Icons.edit_outlined),
                              onPressed: () {
                                Get.dialog(
                                  AlertDialog(
                                    title: Text(key),
                                    content: TextField(
                                      controller: controller,
                                      decoration: InputDecoration(
                                        border: InputBorder.none,
                                      ),
                                      maxLines: 20,
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          Get.back();
                                        },
                                        child: Text(R.current.cancel),
                                      ),
                                      TextButton(
                                        onPressed: () async {
                                          if (pref
                                                  .get(key)
                                                  .runtimeType
                                                  .toString() ==
                                              'String') {
                                            await pref.setString(
                                                key, controller.text);
                                          }
                                          if (pref
                                                  .get(key)
                                                  .runtimeType
                                                  .toString() ==
                                              'int') {
                                            await pref.setInt(key,
                                                int.parse(controller.text));
                                          }
                                          Get.back();
                                        },
                                        child: Text(R.current.sure),
                                      )
                                    ],
                                  ),
                                );
                              }),
                          IconButton(
                            icon: Icon(Icons.delete_outline),
                            onPressed: () {
                              keyList.removeAt(index);
                              pref.remove(key);
                              setState(() {});
                            },
                          )
                        ],
                      ),
                    ),
                  ),
                );
              },
              separatorBuilder: (context, index) {
                // 顯示格線
                return Container(
                  color: Colors.black12,
                  height: 1,
                );
              },
            );
          }
        },
      ),
    );
  }
}
