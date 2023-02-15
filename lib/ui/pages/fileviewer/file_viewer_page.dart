import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_app/src/providers/category_provider.dart';
import 'package:flutter_app/src/r.dart';
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
    super.key,
    required this.title,
    required this.path,
  });

  @override
  State<FileViewerPage> createState() => _FileViewerPageState();
}

class _FileViewerPageState extends State<FileViewerPage> with WidgetsBindingObserver {
  String path = "";
  final List<String> paths = [];
  List<FileSystemEntity> files = [];
  final isDarkModeEnabled = Get.isDarkMode;
  bool showHidden = false;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      getFiles();
    }
  }

  getFiles() async {
    final Directory dir = Directory(path);
    final List<FileSystemEntity> l = dir.listSync();
    files.clear();
    setState(() {
      showHidden = Provider.of<CategoryProvider>(context, listen: false).showHidden;
    });
    for (final file in l) {
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
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final labelAndIconColor = isDarkModeEnabled ? colorScheme.onPrimaryContainer : colorScheme.onPrimary;
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
            children: [
              Text(widget.title),
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
                              color: labelAndIconColor,
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
                                      color: labelAndIconColor,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                  },
                  separatorBuilder: (_, __) => Icon(
                    Icons.arrow_forward_ios,
                    color: labelAndIconColor,
                  ),
                ),
              ),
            ),
          ),
          actions: [
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
            : ListView.builder(
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

                                return Directory(file.path);
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
                      : Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: FileItem(
                            file: file,
                            popTap: (v) async {
                              if (v == 0) {
                                renameDialog(context, file.path, "file");
                              } else if (v == 1) {
                                await File(file.path).delete().catchError((e) {
                                  if (e.toString().contains("Permission denied")) {
                                    MyToast.show(R.current.cannotWrite);
                                  }
                                  return File(file.path);
                                });
                                getFiles();
                              } else if (v == 2) {}
                            },
                          ),
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
  }

  addDialog(BuildContext context, String path) {
    final name = TextEditingController();
    final colorScheme = Theme.of(context).colorScheme;
    Get.dialog(
      CustomAlert(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
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
                children: [
                  SizedBox(
                    height: 40,
                    width: 130,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5.0),
                        ),
                        side: BorderSide(color: Theme.of(context).colorScheme.secondary),
                        backgroundColor: colorScheme.secondary,
                      ),
                      child: Text(
                        R.current.cancel,
                        style: TextStyle(
                          color: colorScheme.onSecondary,
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
                        backgroundColor: colorScheme.tertiary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5.0),
                        ),
                      ),
                      child: Text(
                        R.current.createFolder,
                        style: TextStyle(
                          color: colorScheme.onTertiary,
                        ),
                      ),
                      onPressed: () async {
                        if (name.text.isNotEmpty) {
                          if (!Directory("$path/${name.text}").existsSync()) {
                            await Directory("$path/${name.text}").create().catchError((e) {
                              if (e.toString().contains("Permission denied")) {
                                MyToast.show(R.current.cannotWrite);
                              }
                              return Directory("$path/${name.text}");
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
    final colorScheme = Theme.of(context).colorScheme;
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
            children: [
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
                children: [
                  SizedBox(
                    height: 40,
                    width: 130,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5.0),
                        ),
                        side: BorderSide(color: Theme.of(context).colorScheme.secondary),
                        backgroundColor: colorScheme.secondary,
                      ),
                      child: Text(
                        R.current.cancel,
                        style: TextStyle(
                          color: colorScheme.onSecondary,
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
                        backgroundColor: colorScheme.tertiary,
                      ),
                      child: Text(
                        R.current.rename,
                        style: TextStyle(
                          color: colorScheme.onTertiary,
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
                                return File(path);
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
                                return Directory(path);
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
