// TODO: remove sdk version selector after migrating to null-safety.
// @dart=2.10
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_app/src/r.dart';
import 'package:flutter_app/src/providers/category_provider.dart';
import 'package:flutter_app/src/util/file_utils.dart';
import 'package:flutter_app/ui/other/my_toast.dart';
import "package:flutter_feather_icons/flutter_feather_icons.dart";
import 'package:get/get.dart';
import 'package:path/path.dart' as path_lib;
import 'package:provider/provider.dart';

import 'widgets/custom_alert.dart';
import 'widgets/dir_item.dart';
import 'widgets/file_item.dart';
import 'widgets/path_bar.dart';
import 'widgets/sort_sheet.dart';

class FileViewerPage extends StatefulWidget {
  final String title;
  final String path;

  const FileViewerPage({
    Key key,
    @required this.title,
    @required this.path,
  }) : super(key: key);

  @override
  State<FileViewerPage> createState() => _FileViewerPageState();
}

class _FileViewerPageState extends State<FileViewerPage> with WidgetsBindingObserver {
  String path;
  final List<String> paths = [];
  List<FileSystemEntity> files = [];
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
      showHidden = Provider.of<CategoryProvider>(context, listen: false).showHidden;
    });
    for (FileSystemEntity file in l) {
      if (!showHidden) {
        if (!path_lib.basename(file.path).startsWith(".")) {
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

    files = FileUtils.sortList(files, Provider.of<CategoryProvider>(context, listen: false).sort);
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
  Widget build(BuildContext context) => WillPopScope(
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
              icon: const Icon(
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
                  widget.title,
                ),
              ],
            ),
            bottom: PathBar(
              child: SizedBox(
                height: 50,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    shrinkWrap: true,
                    itemCount: paths.length,
                    itemBuilder: (BuildContext context, int index) {
                      final i = paths[index];
                      final split = i.split("/");
                      return index == 0
                          ? IconButton(
                              icon: Icon(
                                widget.path.toString().contains("emulated") ? FeatherIcons.smartphone : Icons.sd_card,
                                color: index == paths.length - 1
                                    ? Theme.of(context).colorScheme.secondary
                                    : Theme.of(context).textTheme.titleLarge.color,
                              ),
                              onPressed: () {
                                setState(() {
                                  path = paths[index];
                                  paths.removeRange(index + 1, paths.length);
                                });
                                getFiles();
                              },
                            )
                          : InkWell(
                              onTap: () {
                                setState(() {
                                  path = paths[index];
                                  paths.removeRange(index + 1, paths.length);
                                });
                                getFiles();
                              },
                              child: SizedBox(
                                height: 40,
                                child: Center(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 5),
                                    child: Text(
                                      split[split.length - 1],
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: index == paths.length - 1
                                            ? Theme.of(context).colorScheme.secondary
                                            : Theme.of(context).textTheme.titleLarge.color,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                    },
                    separatorBuilder: (BuildContext context, int index) {
                      return const Icon(
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
                    builder: (context) => const SortSheet(),
                  ).then((v) {
                    getFiles();
                  });
                },
                tooltip: R.current.sortBy,
                icon: const Icon(
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
                  padding: const EdgeInsets.only(left: 20),
                  itemCount: files.length,
                  itemBuilder: (BuildContext context, int index) {
                    final file = files[index];
                    return file.toString().split(":")[0] == "Directory"
                        ? DirectoryItem(
                            popTap: (v) async {
                              if (v == 0) {
                                renameDialog(context, file.path, "dir");
                              } else if (v == 1) {
                                await Directory(file.path)
                                    .delete(recursive: true) //將會刪除資料夾內所有東西
                                    .catchError((e) {
                                  if (e.toString().contains("Permission denied")) {
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
                                  if (e.toString().contains("Permission denied")) {
                                    MyToast.show(R.current.cannotWrite);
                                  }
                                });
                                getFiles();
                              } else if (v == 2) {}
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
            tooltip: "Add Folder",
            child: const Icon(FeatherIcons.plus),
          ),
        ),
      );

  addDialog(BuildContext context, String path) {
    final name = TextEditingController();
    Get.dialog(
      CustomAlert(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const SizedBox(height: 15),
              Text(
                R.current.createNewFolder,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 25),
              TextField(
                controller: name,
                keyboardType: TextInputType.text,
              ),
              const SizedBox(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  SizedBox(
                    height: 40,
                    width: 130,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5.0),
                        ),
                        side: BorderSide(color: Theme.of(context).colorScheme.secondary),
                        backgroundColor: Colors.white,
                      ),
                      child: Text(
                        R.current.cancel,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  SizedBox(
                    height: 40,
                    width: 130,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.secondary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5.0),
                        ),
                      ),
                      child: Text(
                        R.current.createFolder,
                        style: const TextStyle(
                          color: Colors.white,
                        ),
                      ),
                      onPressed: () async {
                        if (name.text.isNotEmpty) {
                          if (!Directory("$path/${name.text}").existsSync()) {
                            await Directory("$path/${name.text}").create().catchError((e) {
                              if (e.toString().contains("Permission denied")) {
                                MyToast.show(R.current.cannotWrite);
                              }
                            });
                          } else {
                            MyToast.show(R.current.folderNameAlreadyExists);
                          }
                          Get.back();
                          getFiles();
                        }
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
      barrierDismissible: true,
    );
  }

  renameDialog(BuildContext context, String path, String type) {
    final name = TextEditingController();
    setState(() {
      name.text = path_lib.basename(path);
    });
    Get.dialog(
      CustomAlert(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const SizedBox(height: 15),
              Text(
                R.current.renameItem,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 25),
              TextField(
                controller: name,
                keyboardType: TextInputType.text,
              ),
              const SizedBox(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  SizedBox(
                    height: 40,
                    width: 130,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5.0),
                        ),
                        side: BorderSide(color: Theme.of(context).colorScheme.secondary),
                        backgroundColor: Colors.white,
                      ),
                      child: Text(
                        R.current.cancel,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  SizedBox(
                    height: 40,
                    width: 130,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5.0),
                        ),
                        backgroundColor: Theme.of(context).colorScheme.secondary,
                      ),
                      child: Text(
                        R.current.rename,
                        style: const TextStyle(
                          color: Colors.white,
                        ),
                      ),
                      onPressed: () async {
                        if (name.text.isNotEmpty) {
                          if (type == "file") {
                            if (!File("${path.replaceAll(path_lib.basename(path), "")}${name.text}").existsSync()) {
                              await File(path)
                                  .rename("${path.replaceAll(path_lib.basename(path), "")}${name.text}")
                                  .catchError((e) {
                                if (e.toString().contains("Permission denied")) {
                                  MyToast.show(R.current.cannotWrite);
                                }
                              });
                            } else {
                              MyToast.show(R.current.fileNameAlreadyExists);
                            }
                          } else {
                            if (Directory("${path.replaceAll(path_lib.basename(path), "")}${name.text}").existsSync()) {
                              MyToast.show(R.current.fileNameAlreadyExists);
                            } else {
                              await Directory(path)
                                  .rename("${path.replaceAll(path_lib.basename(path), "")}${name.text}")
                                  .catchError((e) {
                                if (e.toString().contains("Permission denied")) {
                                  MyToast.show(R.current.cannotWrite);
                                }
                              });
                            }
                          }
                          Get.back();
                          getFiles();
                        }
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
      barrierDismissible: true,
    );
  }
}
