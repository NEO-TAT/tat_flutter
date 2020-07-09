import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_app/src/R.dart';
import 'package:flutter_app/src/providers/CategoryProvider.dart';
import 'package:flutter_app/src/util/FileUtils.dart';
import 'package:flutter_app/ui/other/MyToast.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:path/path.dart' as pathLib;
import 'package:provider/provider.dart';

import 'widgets/custom_alert.dart';
import 'widgets/dir_item.dart';
import 'widgets/file_item.dart';
import 'widgets/path_bar.dart';
import 'widgets/sort_sheet.dart';

class FileViewerPage extends StatefulWidget {
  final String title;
  final String path;

  FileViewerPage({
    Key key,
    @required this.title,
    @required this.path,
  }) : super(key: key);

  @override
  _FileViewerPageState createState() => _FileViewerPageState();
}

class _FileViewerPageState extends State<FileViewerPage>
    with WidgetsBindingObserver {
  String path;
  List<String> paths = List();

  List<FileSystemEntity> files = List();
  bool showHidden = false;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      getFiles();
    }
  }

  getFiles() async {
    Directory dir = Directory(path);
    List<FileSystemEntity> l = dir.listSync();
    files.clear();
    setState(() {
      showHidden =
          Provider.of<CategoryProvider>(context, listen: false).showHidden;
    });
    for (FileSystemEntity file in l) {
      if (!showHidden) {
        if (!pathLib.basename(file.path).startsWith(".")) {
          setState(() {
            files.add(file);
          });
        }
      } else {
        setState(() {
          files.add(file);
        });
      }
    }

    files = FileUtils.sortList(
        files, Provider.of<CategoryProvider>(context, listen: false).sort);
//    files.sort((f1, f2) => pathlib.basename(f1.path).toLowerCase().compareTo(pathlib.basename(f2.path).toLowerCase()));
//    files.sort((f1, f2) => f1.toString().split(":")[0].toLowerCase().compareTo(f2.toString().split(":")[0].toLowerCase()));
//    files.sort((f1, f2) => FileSystemEntity.isDirectorySync(f1.path) ==
//        FileSystemEntity.isDirectorySync(f2.path)
//        ? 0
//        : 1);
  }

  @override
  void initState() {
    super.initState();
    path = widget.path;
    getFiles();
    paths.add(widget.path);
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    super.dispose();
    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (paths.length == 1) {
          return true;
        } else {
          paths.removeLast();
          setState(() {
            path = paths.last;
          });
          getFiles();
          return false;
        }
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back,
            ),
            onPressed: () {
              if (paths.length == 1) {
                Navigator.pop(context);
              } else {
                paths.removeLast();
                setState(() {
                  path = paths.last;
                });
                getFiles();
              }
            },
          ),
          elevation: 4,
          title: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                "${widget.title}",
              ),
              Text(
                "$path",
                style: TextStyle(
                  fontSize: 12,
                ),
              ),
            ],
          ),
          bottom: PathBar(
            child: Container(
              height: 50,
              child: Align(
                alignment: Alignment.centerLeft,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  shrinkWrap: true,
                  itemCount: paths.length,
                  itemBuilder: (BuildContext context, int index) {
                    String i = paths[index];
                    List splited = i.split("/");
                    return index == 0
                        ? IconButton(
                            icon: Icon(
                              widget.path.toString().contains("emulated")
                                  ? Feather.smartphone
                                  : Icons.sd_card,
                              color: index == paths.length - 1
                                  ? Theme.of(context).accentColor
                                  : Theme.of(context).textTheme.headline6.color,
                            ),
                            onPressed: () {
                              print(paths[index]);
                              setState(() {
                                path = paths[index];
                                paths.removeRange(index + 1, paths.length);
                              });
                              getFiles();
                            },
                          )
                        : InkWell(
                            onTap: () {
                              print(paths[index]);
                              setState(() {
                                path = paths[index];
                                paths.removeRange(index + 1, paths.length);
                              });
                              getFiles();
                            },
                            child: Container(
                              height: 40,
                              child: Center(
                                child: Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 5),
                                  child: Text(
                                    "${splited[splited.length - 1]}",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: index == paths.length - 1
                                          ? Theme.of(context).accentColor
                                          : Theme.of(context)
                                              .textTheme
                                              .headline6
                                              .color,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                  },
                  separatorBuilder: (BuildContext context, int index) {
                    return Icon(
                      Icons.arrow_forward_ios,
                    );
                  },
                ),
              ),
            ),
          ),
          actions: <Widget>[
            IconButton(
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  builder: (context) => SortSheet(),
                ).then((v) {
                  getFiles();
                });
              },
              tooltip: R.current.sortBy,
              icon: Icon(
                Icons.sort,
              ),
            ),
          ],
        ),
        body: files.isEmpty
            ? Center(
                child: Text(R.current.nothingHere),
              )
            : ListView.separated(
                padding: EdgeInsets.only(left: 20),
                itemCount: files.length,
                itemBuilder: (BuildContext context, int index) {
                  FileSystemEntity file = files[index];
                  return file.toString().split(":")[0] == "Directory"
                      ? DirectoryItem(
                          popTap: (v) async {
                            if (v == 0) {
                              renameDialog(context, file.path, "dir");
                            } else if (v == 1) {
                              await Directory(file.path)
                                  .delete(recursive: true) //將會刪除資料夾內所有東西
                                  .catchError((e) {
                                print(e.toString());
                                if (e
                                    .toString()
                                    .contains("Permission denied")) {
                                  MyToast.show(R.current.cannotWrite);
                                }
                              });
                              getFiles();
                            }
                          },
                          file: file,
                          tap: () {
                            paths.add(file.path);
                            setState(() {
                              path = file.path;
                            });
                            getFiles();
                          },
                        )
                      : FileItem(
                          file: file,
                          popTap: (v) async {
                            if (v == 0) {
                              renameDialog(context, file.path, "file");
                            } else if (v == 1) {
                              await File(file.path).delete().catchError((e) {
                                print(e.toString());
                                if (e
                                    .toString()
                                    .contains("Permission denied")) {
                                  MyToast.show(R.current.cannotWrite);
                                }
                              });
                              getFiles();
                            } else if (v == 2) {
                              print("Share");
                            }
                          },
                        );
                },
                separatorBuilder: (BuildContext context, int index) {
                  return Stack(
                    children: <Widget>[
                      Align(
                        alignment: Alignment.centerRight,
                        child: Container(
                          height: 1,
                          color: Theme.of(context).dividerColor,
                          width: MediaQuery.of(context).size.width - 70,
                        ),
                      ),
                    ],
                  );
                },
              ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => addDialog(context, path),
          child: Icon(Feather.plus),
          tooltip: "Add Folder",
        ),
      ),
    );
  }

  addDialog(BuildContext context, String path) {
    final TextEditingController name = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => CustomAlert(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              SizedBox(height: 15),
              Text(
                R.current.createNewFolder,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              SizedBox(height: 25),
              TextField(
                controller: name,
                keyboardType: TextInputType.text,
              ),
              SizedBox(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Container(
                    height: 40,
                    width: 130,
                    child: OutlineButton(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5.0),
                      ),
                      borderSide:
                          BorderSide(color: Theme.of(context).accentColor),
                      child: Text(
                        R.current.cancel,
                        style: TextStyle(
                          color: Theme.of(context).accentColor,
                        ),
                      ),
                      onPressed: () => Navigator.pop(context),
                      color: Colors.white,
                    ),
                  ),
                  Container(
                    height: 40,
                    width: 130,
                    child: RaisedButton(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5.0),
                      ),
                      child: Text(
                        R.current.createFolder,
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                      onPressed: () async {
                        if (name.text.isNotEmpty) {
                          if (!Directory(path + "/${name.text}").existsSync()) {
                            await Directory(path + "/${name.text}")
                                .create()
                                .catchError((e) {
                              print(e.toString());
                              if (e.toString().contains("Permission denied")) {
                                MyToast.show(R.current.cannotWrite);
                              }
                            });
                          } else {
                            MyToast.show(R.current.folderNameAlreadyExists);
                          }
                          Navigator.pop(context);
                          getFiles();
                        }
                      },
                      color: Theme.of(context).accentColor,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  renameDialog(BuildContext context, String path, String type) {
    final TextEditingController name = TextEditingController();
    setState(() {
      name.text = pathLib.basename(path);
    });
    showDialog(
      context: context,
      builder: (context) => CustomAlert(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              SizedBox(height: 15),
              Text(
                R.current.renameItem,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              SizedBox(height: 25),
              TextField(
                controller: name,
                keyboardType: TextInputType.text,
              ),
              SizedBox(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Container(
                    height: 40,
                    width: 130,
                    child: OutlineButton(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5.0),
                      ),
                      borderSide:
                          BorderSide(color: Theme.of(context).accentColor),
                      child: Text(
                        R.current.cancel,
                        style: TextStyle(
                          color: Theme.of(context).accentColor,
                        ),
                      ),
                      onPressed: () => Navigator.pop(context),
                      color: Colors.white,
                    ),
                  ),
                  Container(
                    height: 40,
                    width: 130,
                    child: RaisedButton(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5.0),
                      ),
                      child: Text(
                        R.current.rename,
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                      onPressed: () async {
                        if (name.text.isNotEmpty) {
                          if (type == "file") {
                            if (!File(path.replaceAll(
                                        pathLib.basename(path), "") +
                                    "${name.text}")
                                .existsSync()) {
                              await File(path)
                                  .rename(path.replaceAll(
                                          pathLib.basename(path), "") +
                                      "${name.text}")
                                  .catchError((e) {
                                print(e.toString());
                                if (e
                                    .toString()
                                    .contains("Permission denied")) {
                                  MyToast.show(R.current.cannotWrite);
                                }
                              });
                            } else {
                              MyToast.show(R.current.fileNameAlreadyExists);
                            }
                          } else {
                            if (Directory(path.replaceAll(
                                        pathLib.basename(path), "") +
                                    "${name.text}")
                                .existsSync()) {
                              MyToast.show(R.current.fileNameAlreadyExists);
                            } else {
                              await Directory(path)
                                  .rename(path.replaceAll(
                                          pathLib.basename(path), "") +
                                      "${name.text}")
                                  .catchError((e) {
                                print(e.toString());
                                if (e
                                    .toString()
                                    .contains("Permission denied")) {
                                  MyToast.show(R.current.cannotWrite);
                                }
                              });
                            }
                          }
                          Navigator.pop(context);
                          getFiles();
                        }
                      },
                      color: Theme.of(context).accentColor,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
